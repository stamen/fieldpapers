#MBTiles Support for paperwalking

* Create a target folder for your MBTiles files. We called our target folder
"uploaded_mbtiles."

* Upload your MBTiles file with the form found on upload_mbtiles.html. You can find a 
test file in the fixtures folder. Also, make sure to check your PHP installation to see 
the file-size limit for uploads. If your MBTiles file is too large, the upload will fail. 
Uploading a file will trigger the uploader.php script.

* The mbtiles.php script will allow you to access individual tiles in a MBTiles file, 
which is essentially a SQLite flat file(SQLite v3.0.0+). You can learn more about
MBTiles with the [MBTiles spec](https://github.com/mapbox/mbtiles-spec/blob/master/1.2/spec.md). 

    To explore your MBTiles file, you can query a database in your file with:

    `select zoom_level, tile_column, tile_row, length(tile_data) from tiles;`

    You will find a quick description of each tile: a tile's zoom level, column number, 
row number, and the file-size of an individual tile.

* Initially, choose a random tile to view, probably one at a low zoom level. Go back to 
your browser and navigate to:

    `../site/www/mbtiles/mbtiles.php/name_of_your_mbtiles_files/zoom_level/tile_column/tile_row.png.`

    You should now be viewing that particular tile in your browser.