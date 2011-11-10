<?php

    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.dirname(__FILE__).'/../lib');
    require_once 'init.php';
    require_once 'data.php';
    require_once 'output.php';

    require_once 'ModestMaps/ModestMaps.php';

    $json = json_decode(file_get_contents('php://input'), true);
    
    //
    // Perform a few basic idiot-checks to verify that we're looking at GeoJSON.
    //
    
    if(!is_array($json))
    {
        die_with_code(400, 'Bad JSON input');
    }

    if($json['type'] != 'FeatureCollection' || !is_array($json['features']))
    {
        die_with_code(400, 'Bad GeoJSON input');
    }
    
    foreach($json['features'] as $feature)
    {
        if(!is_array($feature))
        {
            die_with_code(400, 'Bad JSON input');
        }
    
        if($feature['type'] != 'Feature' || !is_array($feature['geometry']))
        {
            die_with_code(400, 'Bad GeoJSON input');
        }
    }

    //
    // Move on to the actual business of converting GeoJSON to an atlas.
    // Start with a global paper size and orientation for the full document.
    //
    
    $p = $json['properties'];

    $paper_size = (is_array($p) && isset($p['paper_size'])) ? $p['paper_size'] : 'letter';
    $orientation = (is_array($p) && isset($p['orientation'])) ? $p['orientation'] : 'portrait';
    $paper_type = "{$orientation}, {$paper_size}";
    
    if($paper_type == 'portrait, letter') {
        $paper_aspect = PAPER_PORTRAIT_LTR_WIDTH / PAPER_PORTRAIT_LTR_HEIGHT;
    
    } else {
        die_with_code(500, "I don't know how to do this yet, sorry.");
    }
    
    //
    // Iterate over each feature and determine an appropriate extent and zoom.
    // Each feature in the GeoJSON becomes a single page in the atlas.
    //
    
    foreach($json['features'] as $feature)
    {
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

            // Between 150-200dpi on most paper sizes.
            // TODO: make this more flexible.
            $dimensions = new MMaps_Point(1200, 1200);
            
            $coords = $feature['geometry']['coordinates'];
            $center = new MMaps_Location($coords[1], $coords[0]);

            // make a temporary map with the correct center and aspect ratio
            $_mmap = MMaps_mapByCenterZoom($provider, $center, $zoom, $dimensions);

            // make a new extent with the corners of the map above.
            $extent = array($_mmap->pointLocation(new MMaps_Point(0, 0)),
                            $_mmap->pointLocation($mmap->dimensions));
        
        } elseif($feature['geometry']['type'] == 'Polygon') {

            $coords = $feature['geometry']['coordinates'][0];
            
            list($minlon, $minlat) = array($coords[0][0], $coords[0][1]);
            list($maxlon, $maxlat) = array($coords[0][0], $coords[0][1]);
            
            foreach($coords as $coord)
            {
                $minlon = min($minlon, $coord[0]);
                $minlat = min($minlat, $coord[1]);
                $maxlon = max($maxlon, $coord[0]);
                $maxlat = max($maxlat, $coord[1]);
            }
            
            $extent = array(new MMaps_Location($minlat, $minlon),
                            new MMaps_Location($maxlat, $maxlon));
        
        } else {
            die_with_code(500, "I don't know how to do this yet, sorry.");
        }
        
        //
        // If we got this far, we know we have a meaningful zoom and extent
        // for this page, now adjust it to the known aspect ration of the page.
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

        print_r($mmap);
    }

?>