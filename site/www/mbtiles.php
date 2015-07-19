<?php
        header('Content-Type: text/plain');
        $URL_PATH = $_SERVER['PATH_INFO'];
        
        if(preg_match('#^\/([^\/]+)\/(\d+)\/(\d+)\/(\d+)\.\w+$#', $URL_PATH, $matches))
        {
                list($all, $slug, $zoom, $column, $row) = $matches;
        }

		$target_mbtiles_path = "files/mbtiles/" . $slug . ".mbtiles"; // Change
         
        if(!file_exists($target_mbtiles_path))
        {
                header('HTTP/1.1 400');
                exit('The file does not exist.');
        }
        
        $db_mbtiles = new SQLite3($target_mbtiles_path);

        /*Query the database for an individual tile
        An individual tile is identified by zoom_level, tile_column, tile_row   
        The following query will give us access to the tile image data.*/
        
        // Convert
        
        $converted_row = round(pow(2,$zoom) - $row - 1);

        $query = "select tile_data from tiles where zoom_level='" . $zoom . "' and tile_column='" . $column . "' and tile_row='" . $converted_row . "'";
                
        $png_data = $db_mbtiles->querySingle($query);
        
        if ($png_data)
        {
            header('Content-Type: image/png');
            echo $png_data;
        } else {
            //header("HTTP/1.0 404 Not Found");
            
            header('Content-Type: image/png');
            //echo file_get_contents('img/no-tile-here.png');
        }
        
        $db_mbtiles->close();
        
?>
