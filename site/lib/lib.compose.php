<?php

    require_once 'output.php';
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
    
    function get_paper_dimensions($paper_size, $orientation)
    {
        $size_names = array('letter' => 'ltr', 'a3' => 'a3', 'a4' => 'a4');

        $orientation = strtoupper($orientation);
        $paper_size = strtoupper($size_names[strtolower($paper_size)]);
    
        $width = constant("PAPER_{$orientation}_{$paper_size}_WIDTH");
        $height = constant("PAPER_{$orientation}_{$paper_size}_HEIGHT");

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
    
    function create_mmap_from_bounds($paper_size, $orientation, $north, $west, $south, $east)
    {
        list($width_pt, $height_pt) = get_paper_dimensions($paper_size, $orientation);
        $min_width_px = $width_pt * 100/72; // aim for over 100dpi
    
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
        
        $aspect_ratio = $width_pt / $height_pt;
        
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
    */
    function get_mmap_bounds($mmap)
    {
        $northwest = $mmap->pointLocation(new MMaps_Point(0, 0));
        $southeast = $mmap->pointLocation($mmap->dimensions);
        $bounds = array($northwest->lat, $northwest->lon, $southeast->lat, $southeast->lon);
        
        return $bounds;
    }
    
   /**
    * Convert an array of form fields to an atlas composition and queue it up.
    *
    * This should be removed soon, along with compose-print-old.php.
    */
    function compose_from_fields(&$dbh, $form)
    {
        $print = add_print($dbh, 'nobody');
        $page = add_print_page($dbh, $print['id'], 1);
        
        $paper = $form['paper'] ? $form['paper'] : null;
        
        if(preg_match('/^(portrait|landscape)-(letter|a4|a3)$/', $paper, $parts)) {
            $print['orientation'] = $parts[1];
            $print['paper_size'] = $parts[2];
            
        } else {
            die_with_code(500, "Give us a meaningful paper, not \"{$print['paper']}\"\n");
        }
        
        $print['north'] = is_numeric($form['north']) ? floatval($form['north']) : null;
        $print['south'] = is_numeric($form['south']) ? floatval($form['south']) : null;
        $print['east'] = is_numeric($form['east']) ? floatval($form['east']) : null;
        $print['west'] = is_numeric($form['west']) ? floatval($form['west']) : null;
        $print['zoom'] = is_numeric($form['zoom']) ? intval($form['zoom']) : null;
        
        $page['provider'] = $form['provider'] ? $form['provider'] : 'http://tile.openstreetmap.org/{Z}/{X}/{Y}.png';
        
        if(in_array($form['grid'], array('utm', 'mgrs')))
        {
            $page['provider'] .= ",http://tiles.teczno.com/{$form['grid']}/{Z}/{X}/{Y}.png";
        }
        
        $page['north'] = $print['north'];
        $page['south'] = $print['south'];
        $page['east'] = $print['east'];
        $page['west'] = $print['west'];

        //
        // A form submission uses the zoom level of the visible map widget
        // not the intended zoom of the printed map, so we adjust it up to
        // get a higher-resolution print.
        //
        if($print['paper_size'] == 'a3') {
            $page['zoom'] = intval($print['zoom']) + 3;
        
        } else {
            $page['zoom'] = intval($print['zoom']) + 2;
        }
        
        $message = array('action' => 'compose',
                         'paper_size' => $print['paper_size'],
                         'orientation' => $print['orientation'],
                         'pages' => array(
                            array('zoom' => $page['zoom'],
                                  'number' => $page['page_number'],
                                  'provider' => $page['provider'],
                                  'bounds' => array($page['north'], $page['west'], $page['south'], $page['east'])
                                  )
                            )
                         );
        
        set_print($dbh, $print);
        set_print_page($dbh, $page);
    
        $message['print_id'] = $print['id'];
        add_message($dbh, json_encode($message));
        
        return $print;
    }
    
   /**
    * Convert an array of form fields to an atlas composition and queue it up.
    */
    function compose_from_postvars(&$dbh, $post)
    {
        header('Content-Type: text/plain');
        
        $extents = $post['pages'];
        $page_zoom = $post['page_zoom']; // Set a default?
        $paper_size = $post['paper_size'];
        $orientation = $post['orientation'];

        list($width, $height) = get_paper_dimensions($paper_size, $orientation);
        $paper_aspect = $width / $height;
        
        // We have all of the information. Make some pages.       
        $message = array('action' =>            'compose',
                         'paper_size' =>        strtolower($paper_size),
                         'orientation' =>       $orientation,
                         'pages' =>             array()
                        );            
        
        $print = add_print(&$dbh, 'nobody');
        
        $print['paper_size'] = $message['paper_size'];
        $print['orientation'] = $message['orientation'];
        
        foreach($extents as $key => $value)
        {
            list($north, $west, $south, $east) = array_map('floatval', explode(',', $value));
            $mmap = create_mmap_from_bounds($paper_size, $orientation, $north, $west, $south, $east);
            $bounds = get_mmap_bounds($mmap);
            
            $message['pages'][] = array('zoom' => $mmap->coordinate->zoom,
                                        'number' => $key + 1,
                                        'provider' => 'http://tile.openstreetmap.org/{Z}/{X}/{Y}.png', 
                                        'bounds' => $bounds
                                        );
            
            $print['north'] = $bounds[0];
            $print['south'] = $bounds[2];
            $print['east'] = $bounds[3];
            $print['west'] = $bounds[1];
        }
        
        foreach($message['pages'] as $key => $value)
        {
            $number = $key + 1;
            $page = add_print_page($dbh, $print['id'], $number);
            
            $page['zoom'] = $value['zoom'];

            $_page = $value['bounds'];
            
            $page['north'] = $_page[0];
            $page['south'] = $_page[2];
            $page['west'] = $_page[1];
            $page['east'] = $_page[3];
            
            $page['provider'] = $value['provider'];
            
            set_print_page($dbh, $page);
         
            $print['north'] = max($print['north'], $page['north']);
            $print['south'] = min($print['south'], $page['south']);
            $print['west'] = min($print['west'], $page['west']);
            $print['east'] = max($print['east'], $page['east']);
        }
        
        set_print($dbh, $print);
        $message['print_id'] = $print['id'];
        add_message($dbh, json_encode($message));
                
        return $print;
    }
    
   /**
    * Convert a string of GeoJSON data to an atlas composition and queue it up.
    */
    function compose_from_geojson(&$dbh, $data)
    {
        $json = json_decode($data, true);
        
        if(!is_geojson($json))
        {
            die_with_code(400, 'Bad GeoJSON input');
        }
        
        //
        // Move on to the actual business of converting GeoJSON to an atlas.
        // Start with a global paper size and orientation for the full document.
        //
        
        $p = $json['properties'];
    
        $paper_size = (is_array($p) && isset($p['paper_size'])) ? $p['paper_size'] : 'letter';
        $orientation = (is_array($p) && isset($p['orientation'])) ? $p['orientation'] : 'portrait';
        $paper_type = "{$orientation}, {$paper_size}";
        
        list($paper_width, $paper_height) = get_paper_dimensions($paper_size, $orientation);
        $paper_aspect = $paper_width / $paper_height;
        
        $message = array('action' => 'compose',
                         'paper_size' => $paper_size,
                         'orientation' => $orientation,
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
            
            if($paper_aspect > $_mmap_aspect) {
                // paper is wider than the map
                $dim->x *= ($paper_aspect / $_mmap_aspect);
            
            } else {
                // paper is taller than the map
                $dim->y *= ($_mmap_aspect / $paper_aspect);
            }
            
            $mmap = MMaps_mapByCenterZoom($provider, $_mmap_center, $zoom, $dim);
    
            $provider = join(',', $mmap->provider->templates);
            
            $northwest = $mmap->pointLocation(new MMaps_Point(0, 0));
            $southeast = $mmap->pointLocation($mmap->dimensions);
            $bounds = array($northwest->lat, $northwest->lon, $southeast->lat, $southeast->lon);
            
            $message['pages'][] = compact('number', 'provider', 'bounds', 'zoom');
        }
        
        //
        // Make room in the database for the new print and all its pages.
        //
        
        $print = add_print(&$dbh, 'nobody');
        
        $print['paper_size'] = $message['paper_size'];
        $print['orientation'] = $message['orientation'];
    
        $print['north'] = $message['pages'][0]['bounds'][0];
        $print['south'] = $message['pages'][0]['bounds'][2];
        $print['west'] = $message['pages'][0]['bounds'][1];
        $print['east'] = $message['pages'][0]['bounds'][3];
        
        foreach($message['pages'] as $_page)
        {
            $page = add_print_page($dbh, $print['id'], $_page['number']);
            
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
        
        set_print($dbh, $print);
    
        $message['print_id'] = $print['id'];
        add_message($dbh, json_encode($message));
        
        return $print;
    }

?>