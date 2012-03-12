<?php
    require_once '../lib/lib.everything.php';

    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);
    
    if ($_POST['query'])
    {
        $query = $_POST['query'];
            
        $url = 'http://where.yahooapis.com/v1/places.q(' . urlencode($query) . ');count=1?format=json&select=long&appid=' . GEOPLANET_APPID;
        
        // GET the JSON Response with cURL
        $curl_handle = curl_init();
        curl_setopt($curl_handle, CURLOPT_URL, $url);
        curl_setopt($curl_handle, CURLOPT_RETURNTRANSFER, true);
        $api_response = curl_exec($curl_handle);
        curl_close($curl_handle);
        
        $decoded_response = json_decode($api_response, true);
        
        $centroid = $decoded_response['places']['place'][0]['centroid'];
           
        if ($api_response && $decoded_response['places'] && $decoded_response['places']['place'] && $decoded_response['places']['place'][0])
        {
            $make_atlas_url = 'http://'.get_domain_name().get_base_dir().'/make-atlas.php?center='.$centroid['latitude'].urlencode(',').$centroid['longitude'];
            header("Location: $make_atlas_url");
        } else {
            $error_url = 'http://'.get_domain_name().get_base_dir().'/atlas-search-form.php?error=no_response';
            header("Location: $error_url");
        }
        
        exit();
    } else {
        die("Error: there was no query.");
    }

?>