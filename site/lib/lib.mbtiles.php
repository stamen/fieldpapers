<?php

    require_once 'data.php';

    function add_mbtiles(&$dbh, $user_id, $url, $file_path)
    {
        $metadata = extract_mbtiles_metadata($file_path);
                
        $mbtiles_id = generate_id();
        
        $q = sprintf('INSERT INTO mbtiles
                      SET id = %s, 
                      user_id = %s,
                      url = %s,
                      uploaded_file_path = %s,
                      min_zoom=%s,
                      max_zoom=%s,
                      north=%s,
                      south=%s,
                      east=%s,
                      west=%s',
                     $dbh->quoteSmart($mbtiles_id),
                     $dbh->quoteSmart($user_id),
                     $dbh->quoteSmart($url),
                     $dbh->quoteSmart($file_path),
                     $dbh->quoteSmart($metadata['min_zoom']),
                     $dbh->quoteSmart($metadata['max_zoom']),
                     $dbh->quoteSmart($metadata['north']),
                     $dbh->quoteSmart($metadata['south']),
                     $dbh->quoteSmart($metadata['east']),
                     $dbh->quoteSmart($metadata['west']));
                     
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
    
    function extract_mbtiles_metadata($file_path)
    {
        $db_mbtiles = new SQLite3($file_path);

        /*Query the SQLite database for metadata.*/
                
        $minzoom_query = "select value from metadata where name='minzoom'";
        $minzoom = $db_mbtiles->querySingle($minzoom_query);
        
        $maxzoom_query = "select value from metadata where name='maxzoom'";
        $maxzoom = $db_mbtiles->querySingle($maxzoom_query);
        
        $bounds_query = "select value from metadata where name='bounds'";
        $bounds = $db_mbtiles->querySingle($bounds_query);
                
        $bounds_array = explode(',', $bounds);
            
        /* See MBTiles Spec: https://github.com/mapbox/mbtiles-spec/blob/master/1.2/spec.md */
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
            "west" => $west
        );
        
        return $metadata;
    }
    
    function get_mbtiles_by_id(&$dbh, $id)
    {   
        $q = sprintf("SELECT id, user_id, created,
                             is_private, url, uploaded_file_path,
                             min_zoom, max_zoom, north, south, east, west
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
    
?>