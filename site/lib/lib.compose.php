<?php

    require_once 'data.php';
    require_once 'output.php';
    require_once 'lib.forms.php';
    require_once 'ModestMaps/ModestMaps.php';
    
    // basic conversions between millimeters, points, and inches
    define('MMPPT', 0.352777778);
    define('INPPT', 0.013888889);
    define('PTPIN', 1/INPPT);
    define('PTPMM', 1/MMPPT);
    
    // paper sizes in printed points, with 1/2", 1" margins substracted.
    define('PAPER_LANDSCAPE_A3_WIDTH', 420 * PTPMM - 72);
    define('PAPER_LANDSCAPE_A3_HEIGHT', 297 * PTPMM - 108);
    define('PAPER_LANDSCAPE_A4_WIDTH', 297 * PTPMM - 72);
    define('PAPER_LANDSCAPE_A4_HEIGHT', 210 * PTPMM - 108);
    define('PAPER_LANDSCAPE_LTR_WIDTH', 11 * PTPIN - 72);
    define('PAPER_LANDSCAPE_LTR_HEIGHT', 8.5 * PTPIN - 108);

    define('PAPER_PORTRAIT_A3_WIDTH', 297 * PTPMM - 72);
    define('PAPER_PORTRAIT_A3_HEIGHT', 420 * PTPMM - 108);
    define('PAPER_PORTRAIT_A4_WIDTH', 210 * PTPMM - 72);
    define('PAPER_PORTRAIT_A4_HEIGHT', 297 * PTPMM - 108);
    define('PAPER_PORTRAIT_LTR_WIDTH', 8.5 * PTPIN - 72);
    define('PAPER_PORTRAIT_LTR_HEIGHT', 11 * PTPIN - 108);

   /**
    * Perform a few basic idiot-checks to verify that we're looking at GeoJSON.
    */
    function is_geojson($json)
    {
        if(!is_array($json))
        {
            return false;
        }
    
        if($json['type'] != 'FeatureCollection' || !is_array($json['features']))
        {
            return false;
        }
        
        foreach($json['features'] as $feature)
        {
            if(!is_array($feature))
            {
                return false;
            }
        
            if($feature['type'] != 'Feature' || !is_array($feature['geometry']))
            {
                return false;
            }
        }
        
        return true;
    }
    
    function get_printed_dimensions($paper_size, $orientation, $layout)
    {
        $size_names = array('letter' => 'ltr', 'a3' => 'a3', 'a4' => 'a4');

        $orientation = strtoupper($orientation);
        $paper_size = strtoupper($size_names[strtolower($paper_size)]);
    
        $width = constant("PAPER_{$orientation}_{$paper_size}_WIDTH");
        $height = constant("PAPER_{$orientation}_{$paper_size}_HEIGHT");
        
        //
        // Modify the dimensions of the map to cover half the available area.
        //
        
        if($orientation == 'LANDSCAPE' && $layout == 'half-page') {
            $width /= 2;
        
        } elseif($orientation == 'PORTRAIT' && $layout == 'half-page') {
            $height /= 2;
        }
        
        return array($width, $height);
    }
    
   /**
    * Return a four-element geographic bbox for a point and zoom.
    */
    function geojson_point_extent($geometry, $zoom)
    {
        $provider = new MMaps_OpenStreetMap_Provider();
    
        // Between 150-200dpi on most paper sizes.
        // TODO: make this more flexible.
        $dimensions = new MMaps_Point(1200, 1200);
        
        $coords = $geometry['coordinates'];
        $center = new MMaps_Location($coords[1], $coords[0]);

        // make a temporary map with the correct center and aspect ratio
        $mmap = MMaps_mapByCenterZoom($provider, $center, $zoom, $dimensions);

        // make a new extent with the corners of the map above.
        return array($mmap->pointLocation(new MMaps_Point(0, 0)),
                     $mmap->pointLocation($mmap->dimensions));
    }
    
   /**
    * Return a four-element geographic bbox for a polygon.
    */
    function geojson_polygon_extent($geometry)
    {
        $coords = $geometry['coordinates'][0];
        
        list($minlon, $minlat) = array($coords[0][0], $coords[0][1]);
        list($maxlon, $maxlat) = array($coords[0][0], $coords[0][1]);
        
        foreach($coords as $coord)
        {
            $minlon = min($minlon, $coord[0]);
            $minlat = min($minlat, $coord[1]);
            $maxlon = max($maxlon, $coord[0]);
            $maxlat = max($maxlat, $coord[1]);
        }
        
        return array(new MMaps_Location($minlat, $minlon),
                     new MMaps_Location($maxlat, $maxlon));
    }
    
    function create_mmap_from_bounds($paper_size, $orientation, $north, $west, $south, $east, $coverage='full')
    {
        list($printed_width, $printed_height) = get_printed_dimensions($paper_size, $orientation, $coverage);
        $min_width_px = $printed_width * 100/72; // aim for over 100dpi
    
        $nw = new MMaps_Location($north, $west);
        $se = new MMaps_Location($south, $east);
        $osm = new MMaps_OpenStreetMap_Provider();
        
        // loop over larger and larger maps until we trip over the minimum width.
        foreach(range(0, 20) as $zoom)
        {
            $mmap = MMaps_mapByExtentZoom($osm, $nw, $se, $zoom);
            
            if($mmap->dimensions->x > $min_width_px)
                break;
        }
        
        $aspect_ratio = $printed_width / $printed_height;
        
        $mmap = adjust_mmap_dimensions($aspect_ratio, $mmap);
        
        return $mmap;
    }
    
    function adjust_mmap_dimensions($aspect_ratio, $mmap)
    {
        //
        // If we got this far, we know we have a meaningful zoom and extent
        // for this page, now adjust it to the known aspect ratio of the page.
        //
        
        $dim = $mmap->dimensions;
        
        $mmap_center = $mmap->pointLocation(new MMaps_Point($dim->x/2, $dim->y/2));
        $mmap_aspect = $dim->x / $dim->y;
        
        if($aspect_ratio > $mmap_aspect) {
            // paper is wider than the map
            $dim->x *= ($aspect_ratio / $mmap_aspect);
        
        } else {
            // paper is taller than the map
            $dim->y *= ($mmap_aspect / $aspect_ratio);
        }
        
        return MMaps_mapByCenterZoom($mmap->provider, $mmap_center, $mmap->coordinate->zoom, $dim);
    }
    
   /**
    * Return north, west, south, east array for an mmap instance.
    *
    * Optionally inflate the bounds by some factor.
    */
    function get_mmap_bounds($mmap, $inflate=0)
    {
        $northwest = $mmap->pointLocation(new MMaps_Point(0, 0));
        $southeast = $mmap->pointLocation($mmap->dimensions);
        
        $lat_span = $northwest->lat - $southeast->lat;
        $lon_span = $southeast->lon - $northwest->lon;

        $lat_buff = $lat_span * $inflate;
        $lon_buff = $lon_span * $inflate;

        $bounds = array($northwest->lat + $lat_buff,
                        $northwest->lon - $lon_buff,
                        $southeast->lat - $lat_buff,
                        $southeast->lon + $lon_buff);
        
        return $bounds;
    }
    
    /**
     * simple wrapper for refreshing an atlas that calls compose_clone w/ refresh flag set
    **/
    function compose_refresh(&$dbh, $post, $user_id, $refresh_id){
        return compose_clone($dbh, $post, $user_id, $refresh_id, true);
    }

    /**
     * clones an exisiting atlas
     * $clone_id = id of print to be cloned
     * $is_refresh flag will set either the refreshed column or cloned column in the DB with the $clone_id
    **/
    function compose_clone(&$dbh, $post, $user_id, $clone_id, $is_refresh=false){
        $org_print = get_print($dbh, $clone_id);
        $org_pages = get_print_pages($dbh, $clone_id);
        
       // if(!is_array($pages))
       //     return null;


        $message = array('action' =>            'compose',
                         'paper_size' =>        strtolower($org_print['paper_size']),
                         'orientation' =>       $org_print['orientation'],
                         'provider' =>          $org_print['provider'],
                         'layout' =>            $org_print['layout'],
                         'pages' =>             array()
                        );

        // set print
        $print = add_print($dbh, $user_id);
        $print['title'] = $post['atlas_title'];
        $print['text'] = $org_print['text'];
        $print['paper_size'] = $message['paper_size'];
        $print['orientation'] = $message['orientation'];
        $print['layout'] = $message['layout'];
        $print['private'] = $org_print['private'];
        $print['north'] = $org_print['north'];
        $print['south'] = $org_print['south'];
        $print['west'] = $org_print['west'];
        $print['east'] = $org_print['east'];
        $print['country_name'] = $org_print['country_name'];
        $print['country_woeid'] = $org_print['country_woeid'];
        $print['region_name'] = $org_print['region_name'];
        $print['region_woeid'] = $org_print['region_woeid'];
        $print['place_name'] = $org_print['place_name'];
        $print['place_woeid'] = $org_print['place_woeid'];
        if($is_refresh){
            $print['refreshed'] = $clone_id;
            $print['cloned'] = NULL;
        }else{
            $print['refreshed'] = NULL;
            $print['cloned'] = $clone_id;
        }
        // create messages
        foreach($org_pages as $org_page){
            $bounds = array(floatval($org_page['north']), floatval($org_page['west']), floatval($org_page['south']), floatval($org_page['east']));
            $text = trim(sprintf("%s\n\n%s", $print['title'], $print['text']));

            if($org_page['page_number'] == 'i'){
                $message['pages'][] = array('number' => 'i',
                                            'zoom' => intval($org_page['zoom']),
                                            'bounds' => $bounds,
                                            'provider' => $org_page['provider'],
                                            'role' => 'index',
                                            'text' => ''
                                            );
            }else{
                $message['pages'][] = array('zoom' => intval($org_page['zoom']),
                                            'number' => $org_page['page_number'],
                                            'provider' => $org_page['provider'],
                                            'bounds' => $bounds,
                                            'text' => $text
                                            );
            }
        }

        // create pages in DB
        foreach($message['pages'] as $i => $value)
        {
            $page = add_print_page($dbh, $print['id'], $value['number']);

            $page['zoom'] = $value['zoom'];

            $_page = $value['bounds'];

            $page['north'] = $_page[0];
            $page['south'] = $_page[2];
            $page['west'] = $_page[1];
            $page['east'] = $_page[3];

            $page['provider'] = $value['provider'];

            set_print_page($dbh, $page);

            // add grid overlay to the printed output of each non-index page:

            /* Disabled after fixing the URL until UI is available
            if($value['role'] != 'index')
                $message['pages'][$i]['provider'] = "{$value['provider']},http://tile.stamen.com/utm/{Z}/{X}/{Y}.png";
             */
        }

        // Not sure what forms table is or does but leaving it in for now (SeanC)
        if($post['form_id'] && $form = get_form($dbh, $post['form_id']))
        {
            $print['form_id'] = $form['id'];

            if($form['parsed']) {
                $message['form_fields'] = get_form_fields($dbh, $form['id']);

            } else {
                // The form hasn't been parsed yet, probably because
                // compose-atlas.php was called with just a form_url.

                $message['form_id'] = $form['id'];
                $message['form_url'] = $form['form_url'];
            }
        }


        
        $print['progress'] = 0.1; // the first 10% is getting it queued

        set_print($dbh, $print);
        $message['print_id'] = $print['id'];

        // queue the task
        queue_task("tasks.composePrint", array("http://" . SERVER_NAME, API_PASSWORD), $message);

        return $print;
    }




    
   /**
    * Convert an array of form fields to an atlas composition and queue it up.
    */
    function compose_from_postvars(&$dbh, $post, $user_id)
    {
        $extents = $post['pages'];
        $paper_size = isset($post['paper_size']) ? $post['paper_size'] : 'letter';
        $orientation = isset($post['orientation']) ? $post['orientation'] : 'portrait';
        $layout = isset($post['layout']) ? $post['layout'] : 'full-page';
        $provider = $post['provider'];
        $overlay = $post['overlay'];
        $title = $post['atlas_title'];
        $grid = filter_var($post['grid'], FILTER_VALIDATE_BOOLEAN) ? 1 : 0;
        $redcross = filter_var($post['redcross'], FILTER_VALIDATE_BOOLEAN) ? 1 : 0;
        $private = filter_var($post['private'], FILTER_VALIDATE_BOOLEAN) ? 1 : 0;
        
        if(!is_array($extents))
            return null;
    
        //
        // "orientation" above refers to the *map*, so if we want half-size
        // we'll need to flip the orientation of the overall printed sheet
        // to accommodate it.
        //
        if($orientation == 'landscape' && $layout == 'half-page') {
            $orientation = 'portrait';
        
        } elseif($orientation == 'portrait' && $layout == 'half-page') {
            $orientation = 'landscape';
        }
        
        list($printed_width, $printed_height) = get_printed_dimensions($paper_size, $orientation, $layout);
        $printed_aspect = $printed_width / $printed_height;
        
        // We have all of the information. Make some pages.       
        $message = array('action' =>            'compose',
                         'paper_size' =>        strtolower($paper_size),
                         'orientation' =>       $orientation,
                         'provider' =>          $provider,
                         'layout' =>            $layout,
                         'pages' =>             array()
                        );            
        
        $print = add_print($dbh, $user_id);
        
        $print['title'] = $title;
        $print['text'] = trim($post['atlas_text']);
        $print['paper_size'] = $message['paper_size'];
        $print['orientation'] = $message['orientation'];
        $print['layout'] = $message['layout'];
        $print['private'] = $private;
        
        // build up bounds for each page in the message
        
        $print['north'] = -90;
        $print['east'] = -180;
        $print['south'] = 90;
        $print['west'] = 180;
        
        foreach($extents as $key => $value)
        {
            list($north, $west, $south, $east) = array_map('floatval', explode(',', $value));
            $mmap = create_mmap_from_bounds($paper_size, $orientation, $north, $west, $south, $east, $layout);
            $bounds = get_mmap_bounds($mmap);
            
            $text = trim(sprintf("%s\n\n%s", $post['atlas_title'], $post['atlas_text']));
            
            $message['pages'][] = array('zoom' => $mmap->coordinate->zoom,
                                        'number' => $key,
                                        'provider' => $provider,
                                        'bounds' => $bounds,
                                        'text' => $text
                                        );
            
            $print['north'] = max($print['north'], $bounds[0]);
            $print['south'] = min($print['south'], $bounds[2]);
            $print['west'] = min($print['west'], $bounds[1]);
            $print['east'] = max($print['east'], $bounds[3]);
        }
        
        // prepare the index page and add it to the message for safekeeping.
        if(count($extents) > 1)
        {
            $mmap = create_mmap_from_bounds($paper_size, $orientation, $print['north'], $print['west'], $print['south'], $print['east'], $layout);
            
            $index = array('number' => 'i',
                           'zoom' => $mmap->coordinate->zoom,
                           'bounds' => get_mmap_bounds($mmap, 0.1),
                           'provider' => $provider,
                           'role' => 'index',
                           'text' => ''
                           );
    
            array_unshift($message['pages'], $index);
        }

        // create pages based on message contents
        
        foreach($message['pages'] as $i => $value)
        {
            $page = add_print_page($dbh, $print['id'], $value['number']);
            
            $page['zoom'] = $value['zoom'];

            $_page = $value['bounds'];
            
            $page['north'] = $_page[0];
            $page['south'] = $_page[2];
            $page['west'] = $_page[1];
            $page['east'] = $_page[3];
            
            $page['provider'] = $value['provider'];
            
            set_print_page($dbh, $page);
            
            // add grid overlay to the printed output of each non-index page:
            
            if($value['role'] != 'index' && $grid)
                $message['pages'][$i]['provider'] = "{$value['provider']},http://tile.stamen.com/utm/{Z}/{X}/{Y}.png";
             
            if($redcross)
                $message['pages'][$i]['provider'] = "{$value['provider']},http://a.tiles.mapbox.com/v3/americanredcross.HAIYAN_Atlas_Bounds/{Z}/{X}/{Y}.png";
        
            if($overlay)
                $message['pages'][$i]['provider'] = "{$value['provider']},{$overlay}";



        }
        
        // Deal with WOEIDs
        
        $place = latlon_placeinfo(.5 * ($print['north'] + $print['south']), .5 * ($print['west'] + $print['east']), $post['page_zoom'] - 3);
        $print['country_name'] = $place[0];
        $print['country_woeid'] = $place[1];
        $print['region_name'] = $place[2];
        $print['region_woeid'] = $place[3];
        $print['place_name'] = $place[4];
        $print['place_woeid'] = $place[5];
        
        if($post['form_id'] && $form = get_form($dbh, $post['form_id']))
        {
            $print['form_id'] = $form['id'];
            
            if($form['parsed']) {
                $message['form_fields'] = get_form_fields($dbh, $form['id']);
            
            } else {
                // The form hasn't been parsed yet, probably because
                // compose-atlas.php was called with just a form_url.
                
                $message['form_id'] = $form['id'];
                $message['form_url'] = $form['form_url'];
            }
        }
        
        $print['progress'] = 0.0;
        
        set_print($dbh, $print);
        $message['print_id'] = $print['id'];

        // queue the task
        queue_task("tasks.composePrint", array("http://" . SERVER_NAME, API_PASSWORD), $message);
                
        return $print;
    }
    
   /**
    * Convert a string of GeoJSON data to an atlas composition and queue it up.
    */
    function compose_from_geojson(&$dbh, $data)
    {
        $json = json_decode($data, true);
        
        if(!is_geojson($json))
            return null;
        
        //
        // Move on to the actual business of converting GeoJSON to an atlas.
        // Start with a global paper size and orientation for the full document.
        //
        
        $p = $json['properties'];
    
        $paper_size = (is_array($p) && isset($p['paper_size'])) ? $p['paper_size'] : 'letter';
        $orientation = (is_array($p) && isset($p['orientation'])) ? $p['orientation'] : 'portrait';
        $layout = (is_array($p) && isset($p['layout'])) ? $p['layout'] : 'full-page';
        
        //
        // "orientation" above refers to the *map*, so if we want half-size
        // we'll need to flip the orientation of the overall printed sheet
        // to accommodate it.
        //
        if($orientation == 'landscape' && $layout == 'half-page') {
            $orientation = 'portrait';
        
        } elseif($orientation == 'portrait' && $layout == 'half-page') {
            $orientation = 'landscape';
        }
        
        list($printed_width, $printed_height) = get_printed_dimensions($paper_size, $orientation, $layout);

        $printed_aspect = $printed_width / $printed_height;
        $paper_type = "{$orientation}, {$paper_size}";
        
        $message = array('action' => 'compose',
                         'paper_size' => $paper_size,
                         'orientation' => $orientation,
                         'layout' => $layout,
                         'pages' => array());
        
        //
        // Iterate over each feature and determine an appropriate extent and zoom.
        // Each feature in the GeoJSON becomes a single page in the atlas.
        //
        
        foreach($json['features'] as $f => $feature)
        {
            $number = $f + 1;
        
            //
            // Check the properties for a provider and explicit zoom.
            //
            
            $p = $feature['properties'];
    
            $provider = (is_array($p) && isset($p['provider']))
                ? new MMaps_Templated_Spherical_Mercator_Provider($p['provider'])
                : new MMaps_OpenStreetMap_Provider();
            
            $explicit_zoom = is_array($p) && is_numeric($p['zoom']);
            $zoom = $explicit_zoom ? intval($p['zoom']) : 16;

            $mark = is_array($p['mark']) ? $p['mark'] : null;
            $fuzzy = is_array($p['fuzzy']) ? $p['fuzzy'] : null;
            $text = isset($p['text']) ? $p['text'] : null;
            
            //
            // Determine extent based on geometry type and zoom level.
            //
            
            $extent = null;
            
            if($feature['geometry']['type'] == 'Point') {
                $extent = geojson_point_extent($feature['geometry'], $zoom);
            
            } elseif($feature['geometry']['type'] == 'Polygon') {
                $extent = geojson_polygon_extent($feature['geometry']);
            
            } else {
                die_with_code(500, "I don't know how to do this yet, sorry.");
            }
            
            //
            // If we got this far, we know we have a meaningful zoom and extent
            // for this page, now adjust it to the known aspect ratio of the page.
            //
    
            $_mmap = MMaps_mapByExtentZoom($provider, $extent[0], $extent[1], $zoom);
            $dim = $_mmap->dimensions;
            
            $_mmap_center = $_mmap->pointLocation(new MMaps_Point($dim->x/2, $dim->y/2));
            $_mmap_aspect = $dim->x / $dim->y;
            
            if($printed_aspect > $_mmap_aspect) {
                // paper is wider than the map
                $dim->x *= ($printed_aspect / $_mmap_aspect);
            
            } else {
                // paper is taller than the map
                $dim->y *= ($_mmap_aspect / $printed_aspect);
            }
            
            $mmap = MMaps_mapByCenterZoom($provider, $_mmap_center, $zoom, $dim);
    
            $provider = join(',', $mmap->provider->templates);
            
            $northwest = $mmap->pointLocation(new MMaps_Point(0, 0));
            $southeast = $mmap->pointLocation($mmap->dimensions);
            $bounds = array($northwest->lat, $northwest->lon, $southeast->lat, $southeast->lon);
            
            $message['pages'][] = compact('number', 'provider', 'bounds', 'zoom', 'text', 'mark', 'fuzzy');
        }
        
        //
        // Make room in the database for the new print and all its pages.
        //
        
        $print = add_print($dbh, 'nobody');
        
        $print['paper_size'] = $message['paper_size'];
        $print['orientation'] = $message['orientation'];
        $print['layout'] = $message['layout'];
    
        $print['north'] = $message['pages'][0]['bounds'][0];
        $print['south'] = $message['pages'][0]['bounds'][2];
        $print['west'] = $message['pages'][0]['bounds'][1];
        $print['east'] = $message['pages'][0]['bounds'][3];
        
        foreach($message['pages'] as $_page)
        {
            $page = add_print_page($dbh, $print['id'], $_page['number']);
            $page['text'] = $_page['text'];
            
            $page['provider'] = $_page['provider'];
            $page['zoom'] = $_page['zoom'];
        
            $page['north'] = $_page['bounds'][0];
            $page['south'] = $_page['bounds'][2];
            $page['west'] = $_page['bounds'][1];
            $page['east'] = $_page['bounds'][3];
            
            set_print_page($dbh, $page);
    
            $print['north'] = max($print['north'], $page['north']);
            $print['south'] = min($print['south'], $page['south']);
            $print['west'] = min($print['west'], $page['west']);
            $print['east'] = max($print['east'], $page['east']);
        }
        
        $print['progress'] = 0.1; // the first 10% is getting it queued
        
        set_print($dbh, $print);
    
        $message['print_id'] = $print['id'];

        // queue the task
        queue_task("tasks.composePrint", array("http://" . SERVER_NAME, API_PASSWORD), $message);
        
        return $print;
    }

?>
