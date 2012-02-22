<?php

    function print_to_geojson($print, $pages)
    {
        $geojson = array(
            'type' => 'FeatureCollection',
            'properties' => array('paper_size' => $print['paper_size'], 'orientation' => $print['orientation']),
            'features' => array()
        );
        
        foreach($pages as $page)
        {
            $north = floatval($page['north']);
            $south = floatval($page['south']);
            $west = floatval($page['west']);
            $east = floatval($page['east']);
        
            $feature = array(
                'type' => 'Feature',
                'properties' => array('provider' => $page['provider'], 'zoom' => intval($page['zoom'])),
                'geometry' => array(
                    'type' => 'Polygon',
                    'coordinates' => array(array(
                        array($west, $north), array($east, $north),
                        array($east, $south), array($west, $south),
                        array($west, $north)
                    ))
                )
            );
            
            $geojson['features'][] = $feature;
        }
        
        return json_encode($geojson);
    }

?>