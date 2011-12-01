<?php
        header('Content-Type: text/plain');
        //path_info = /slug/z/x/y.png
        $URL_PATH = $_SERVER['PATH_INFO'];

        //echo $URL_PATH . "\n";

        if(preg_match('#^\/([^\/]+)\/(\d+)\/(\d+)\/(\d+)\.\w+$#', $URL_PATH, $matches))
        {
                list($all, $slug, $zoom, $column, $row) = $matches;
        }

        //echo "slug: " . $slug . "\n";
        //echo "zoom: " . $zoom . "\n"; 


        $target_mbtiles_path = "uploaded_mbtiles/" . $slug . ".mbtiles";

        //echo $target_mbtiles_path . "\n";

        //Check to see if there's a file to open -- probably a 400
        if(!file_exists($target_mbtiles_path))
        {
                header('HTTP/1.1 400');
                exit('The file does not exist.');
        } else {
                //echo "\n" . "The file exists!";
        }

        //echo "\n" . "Something happening.";   

        //$db_mbtiles = sqlite_open($target_mbtiles_path, 0666, $sqliteerror);
        //if (!$db_mbtiles) die ($sqliteerror);

        $db_mbtiles = new SQLite3($target_mbtiles_path);

        //echo 'Is anything happening?';

        /*Query the database for an individual tile
        An individual tile is identified by zoom_level, tile_column, tile_row   
        The following query will give us access to the tile image data.*/

        $query = "select tile_data from tiles where zoom_level='" . $zoom . "' and tile_column='" . $column . "' and tile_row='" . $row . "'";

        //$result = $db_mbtiles->query($query);
        //$result = sqlite_query($db_mbtiles, $query);
        //if (!$result) die ("The query failed.");

        //$png_data = sqlite_fetch_single($result);
                
        $png_data = $db_mbtiles->querySingle($query);

        header('Content-Type: image/png');
        echo $png_data;
        $db_mbtiles->close();
        //sqlite_close($db_mbtiles);
?>
