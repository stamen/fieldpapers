<?php
	//Upload mbtiles to the server.
	
	$target_mbtiles_folder = "uploaded_mbtiles/";
	
	$target_mbtiles_path = $target_mbtiles_folder . basename($_FILES['uploaded_mbtiles']['name']);
	
	if(move_uploaded_file($_FILES['uploaded_mbtiles']['tmp_name'], $target_mbtiles_path)){
		echo basename($_FILES['uploaded_mbtiles']['name']) . " has been successfully uploaded";
	} else {
		echo "Upload of " . basename($_FILES['uploaded_mbtiles']['name']) . " was unsuccessful.";
	}
	
	//File is now sitting on the server at uploaded_tiles/some_name.mbtiles.
?>