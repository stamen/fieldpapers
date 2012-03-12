<?php

    require_once 'data.php';

    function add_mbtiles(&$dbh, $user_id, $url, $file_name, $file_path)
    {
        $mbtiles_data = get_mbtiles_data($file_path);
                        
        $mbtiles_id = generate_id();
        
        $q = sprintf('INSERT INTO mbtiles
                      SET id = %s, 
                      user_id = %s,
                      url = %s,
                      uploaded_file = %s,
                      min_zoom = %d,
                      max_zoom = %d,
                      center_zoom = %d,
                      center_x_coord = %d,
                      center_y_coord = %d',
                     $dbh->quoteSmart($mbtiles_id),
                     $dbh->quoteSmart($user_id),
                     $dbh->quoteSmart($url),
                     $dbh->quoteSmart($file_name),
                     $dbh->quoteSmart($mbtiles_data['min_zoom']),
                     $dbh->quoteSmart($mbtiles_data['max_zoom']),
                     $dbh->quoteSmart($mbtiles_data["center_coordinates"]['zoom']),
                     $dbh->quoteSmart($mbtiles_data["center_coordinates"]['x']),
                     $dbh->quoteSmart($mbtiles_data["center_coordinates"]['y']));
                     
        error_log(preg_replace('/\s+/', ' ', $q));

        $res = $dbh->query($q);
        
        if(PEAR::isError($res)) 
        {
            if($res->getCode() == DB_ERROR_ALREADY_EXISTS)
                continue;

            die_with_code(500, "{$res->message}\n{$q}\n");
        }
        
        return get_mbtiles_by_id($dbh, $mbtiles_id);
    }
    
    function get_mbtiles_data($file_path)
    {
        $db_mbtiles = new SQLite3($file_path);
        
        // Min Zoom and Max Zoom
        
        $zoom_range_query = "select min(zoom_level), max(zoom_level) from tiles";
        $zoom_range_results = $db_mbtiles->query($zoom_range_query);
        
        $zoom_range = $zoom_range_results->fetchArray();
        
        $min_zoom = $zoom_range[0];
        $max_zoom = $zoom_range[1];
        
        // Get zoom, column, and row for each tile
        
        $query = "select zoom_level, avg(tile_column), avg(tile_row) from tiles group by zoom_level";
        $results = $db_mbtiles->query($query);
        
        $rows = array();
        
        while ($row = $results->fetchArray())
        {
            $rows[] = $row;
        }
        
        $center_tile = $rows[floor(.5*count($rows))];
                
        $center_tile_zoom = $center_tile[0];
        $center_tile_x = floor($center_tile[1]); // Column
        $center_tile_y = round(pow(2,$center_tile_zoom) - $center_tile[2] - 1); // Converted Row
        
        $mbtiles_data = array("min_zoom" => $min_zoom,
                              "max_zoom" => $max_zoom,
                              "center_coordinates" => array("zoom" => $center_tile_zoom,
                                                            "x" => intval($center_tile_x),
                                                            "y" => intval($center_tile_y)
                                                            )
                            );
                
        return $mbtiles_data;
    }
    
    /*
    function extract_mbtiles_metadata($file_path)
    {
        $db_mbtiles = new SQLite3($file_path);

        // Query the SQLite database for metadata.
                
        $minzoom_query = "select value from metadata where name='minzoom'";
        $minzoom = $db_mbtiles->querySingle($minzoom_query);
        
        $maxzoom_query = "select value from metadata where name='maxzoom'";
        $maxzoom = $db_mbtiles->querySingle($maxzoom_query);
        
        $center_query = "select value from metadata where name='center'";
        $center = $db_mbtiles->querySingle($center_query);
        
        $center_array = explode(',', $center);
        $center_lat = $center_array[1];
        $center_lon = $center_array[0];
        
        $bounds_query = "select value from metadata where name='bounds'";
        $bounds = $db_mbtiles->querySingle($bounds_query);
                
        $bounds_array = explode(',', $bounds);
            
        $west = $bounds_array[0];
        $south = $bounds_array[1];
        $east = $bounds_array[2];
        $north = $bounds_array[3];
        
        $metadata = array(
            "min_zoom" => $minzoom,
            "max_zoom" => $maxzoom,
            "north" => $north,
            "south" => $south,
            "east" => $east,
            "west" => $west,
            "center_lat" => $center_lat,
            "center_lon" => $center_lon
        );
        
        return $metadata;
    }
    */
    
    function get_mbtiles_by_id(&$dbh, $id)
    {   
        $q = sprintf("SELECT id, user_id, created,
                             is_private, url, uploaded_file,
                             min_zoom, max_zoom, center_zoom,
                             center_x_coord, center_y_coord
                      FROM mbtiles
                      WHERE id=%s",
                      $dbh->quoteSmart($id));
                     
        error_log(preg_replace('/\s+/', ' ', $q));

        $res = $dbh->query($q);
        
        if(PEAR::isError($res)) 
        {
            if($res->getCode() == DB_ERROR_ALREADY_EXISTS)
                continue;

            die_with_code(500, "{$res->message}\n{$q}\n");
        }
        
        $row = $res->fetchRow(DB_FETCHMODE_ASSOC);
        
        return $row;
    }
    
    function get_mbtiles_by_user_id(&$dbh, $user_id)
    {   
        $q = sprintf("SELECT id, user_id, created,
                             is_private, url, uploaded_file,
                             min_zoom, max_zoom, center_zoom,
                             center_x_coord, center_y_coord
                      FROM mbtiles
                      WHERE user_id=%s
                      ORDER BY uploaded_file ASC",
                      $dbh->quoteSmart($user_id));
                     
        error_log(preg_replace('/\s+/', ' ', $q));

        $res = $dbh->query($q);
        
        if(PEAR::isError($res)) 
        {
            if($res->getCode() == DB_ERROR_ALREADY_EXISTS)
                continue;

            die_with_code(500, "{$res->message}\n{$q}\n");
        }
        
        $rows = array();
        
        while($row = $res->fetchRow(DB_FETCHMODE_ASSOC))
            $rows[] = $row;
        
        return $rows;
    }
    
?>