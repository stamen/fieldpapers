<?php

    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'../lib');
    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'/usr/home/migurski/pear/lib');
    require_once 'init.php';
    require_once 'data.php';
    
    /*
    header('Content-Type: text/plain');
    print_r($_POST);
    die();
    */
    
    list($user_id, $language) = read_userdata($_COOKIE['visitor'], $_SERVER['HTTP_ACCEPT_LANGUAGE']);

    $north = is_numeric($_POST['north']) ? floatval($_POST['north']) : null;
    $south = is_numeric($_POST['south']) ? floatval($_POST['south']) : null;
    $east = is_numeric($_POST['east']) ? floatval($_POST['east']) : null;
    $west = is_numeric($_POST['west']) ? floatval($_POST['west']) : null;
    $zoom = is_numeric($_POST['zoom']) ? intval($_POST['zoom']) : null;
    $orientation = $_POST['orientation'] ? $_POST['orientation'] : null;
    $provider = $_POST['provider'] ? $_POST['provider'] : null;
    
    $dbh =& get_db_connection();
    
    $user = $user_id ? get_user($dbh, $user_id) : add_user($dbh);

    if($user)
        setcookie('visitor', write_userdata($user['id'], $language), time() + 86400 * 31);

    function latlon_placeinfo($lat, $lon, $zoom)
    {
        $req = new HTTP_Request('http://api.flickr.com/services/rest/');
        $req->addQueryString('method', 'flickr.places.findByLatLon');
        $req->addQueryString('lat', $lat);
        $req->addQueryString('lon', $lon);
        $req->addQueryString('accuracy', $zoom);
        $req->addQueryString('format', 'php_serial');
        $req->addQueryString('api_key', FLICKR_KEY);

        $res = $req->sendRequest();
        
        if(PEAR::isError($res))
            return '';

        if($req->getResponseCode() == 200)
        {
            $rsp = unserialize($req->getResponseBody());
            
            if(is_array($rsp['places']) && is_array($rsp['places']['place']))
            {
                $places = $rsp['places']['place'];
                
                if(is_array($places[0]) && $places[0]['name'])
                {
                    list($place_name, $place_woeid) = array($places[0]['name'], $places[0]['woeid']);
                    
                    $req = new HTTP_Request('http://api.flickr.com/services/rest/');
                    $req->addQueryString('method', 'flickr.places.getInfo');
                    $req->addQueryString('woe_id', $place_woeid);
                    $req->addQueryString('format', 'php_serial');
                    $req->addQueryString('api_key', FLICKR_KEY);
            
                    $res = $req->sendRequest();
                    
                    if(PEAR::isError($res))
                        return array(null, null, null, null, null, null);
            
                    $rsp = unserialize($req->getResponseBody());
                    
                    if(is_array($rsp) && is_array($rsp['place']))
                    {
                        list($country, $region) = array($rsp['place']['country'], $rsp['place']['region']);
                        
                        if(is_array($country))
                            list($country_name, $country_woeid) = array($country['_content'], $country['woeid']);
                        
                        if(is_array($region))
                            list($region_name, $region_woeid) = array($region['_content'], $region['woeid']);
                    }
                    
                    return array($country_name, $country_woeid, $region_name, $region_woeid, $place_name, $place_woeid);
                }
            }
        }
        
        return array(null, null, null, null, null, null);
    }
    
    function compose_map_image($provider, $north, $south, $east, $west, $zoom, $width, $height)
    {
        $hostports = explode(',', WSCOMPOSE_HOSTPORTS);
        shuffle($hostports);
        
        foreach($hostports as $hostport)
        {
            $req = new HTTP_Request("http://{$hostport}/");
            $req->addQueryString('provider', $provider);
            $req->addQueryString('latitude', ($north + $south) / 2);
            $req->addQueryString('longitude', ($east + $west) / 2);
            $req->addQueryString('zoom', $zoom);
            $req->addQueryString('width', $width);
            $req->addQueryString('height', $height);
            
            $res = $req->sendRequest();
            
            if(PEAR::isError($res))
                continue;
    
            if($req->getResponseCode() == 200)
            {
                // return some raw PNG data
                return $req->getResponseBody();
            }
        }

        die_with_code(500, "Tried all the ws-compose host-ports, and none of them worked.\n");
    }
    
    function compose_map($print)
    {
        list($width, $height) = ($print['orientation'] == 'portrait')
            ? array(360, 480 - 24)
            : array(480, 360 - 24);
        
        $png = compose_map_image($print['provider'], $print['north'], $print['south'], $print['east'], $print['west'], $print['zoom'], $width, $height);

        // post a preview
        $print['preview_url'] = post_file("prints/{$print['id']}/preview.png", $png, 'image/png');
        
        if(PEAR::isError($print['preview_url']))
            die_with_code(500, "{$print['preview_url']->message}\n{$q}\n");
        
        $zoom = $print['zoom'];
        $max_zoom = min(18, $print['zoom'] + 2);
        
        while($zoom < $max_zoom)
        {
            $zoom += 1;
            $width *= 2;
            $height *= 2;
        }

        $png = compose_map_image($print['provider'], $print['north'], $print['south'], $print['east'], $print['west'], $zoom, $width, $height);

        $print_url = 'http://'.get_domain_name().get_base_dir().'/print.php?id='.urlencode($print['id']);
    
        $pdf = new FPDF($print['orientation'] == 'portrait' ? 'P' : 'L', 'pt', 'letter');
        $pdf->addPage();
        
        $icon_filename = realpath(dirname(__FILE__).'/../lib/print/icon.png');
        $pdf->image($icon_filename, 35.99, 42.87, 19.2, 25.6);
        
        $hand_filename = realpath(dirname(__FILE__).'/../lib/print/Hand.png');
        $pdf->image($hand_filename, $pdf->w - 96, 30, 66, 48);
        
        $map_img = imagecreatefromstring($png);
        $map_filename = tempnam(TMP_DIR, 'composed-map-');
        imagejpeg($map_img, $map_filename, 75);
        
        if($print['orientation'] == 'portrait') {
            $pdf->image($map_filename, 36, 72, 540, 684, 'jpg');
        
        } else {
            $pdf->image($map_filename, 36, 72, 720, 504, 'jpg');
        }
        
        $pdf->setFont('Helvetica', 'B', 24);
        $pdf->text(62.61, 68.49, 'Walking Papers');
        
        $pdf->setFillColor(0xFF);
        $pdf->rect(35, $pdf->h - 63, 200, 28, 'F');
        
        $ccbysa_filename = realpath(dirname(__FILE__).'/../lib/print/CCBYSA.png');
        $pdf->image($ccbysa_filename, 30, $pdf->h - 60, 67, 30);

        $pdf->setFont('Helvetica', '', 9);
        $pdf->text($pdf->w - 358, 57.74, 'Help improve OpenStreetMap by drawing on this map, then visit');
        $pdf->text($pdf->w - 358, 68.74, $print_url);
        $pdf->text(99, $pdf->h - 47.5, 'Map data ©2009 CC-BY-SA');
        $pdf->text(99, $pdf->h - 36.5, 'OpenStreetMap.org contributors');

        $size = 64;
        $pad = 8;
        
        $pdf->setFillColor(0xFF);
        $pdf->rect($pdf->w - 36 - $size - $pad, $pdf->h - 36 - $size - $pad, $size + $pad * 2, $size + $pad * 2, 'F');

        $req = new HTTP_Request('http://chart.apis.google.com/chart?chs=264x264&cht=qr&chld=Q|0');
        $req->addQueryString('chl', $print_url);
        $res = $req->sendRequest();
        
        if(PEAR::isError($res))
            die_with_code(500, "{$res->message}\n{$q}\n");
        
        $code_img = imagecreatefromstring($req->getResponseBody());
        $code_filename = tempnam(TMP_DIR, 'composed-code-');
        imagepng($code_img, $code_filename);
        $pdf->image($code_filename, $pdf->w - 36 - $size, $pdf->h - 36 - $size, $size, $size, 'png');
        
        $pdf_content = $pdf->output('', 'S');
        
        // post the PDF
        $url = new Net_URL($print['pdf_url']);
        $print['pdf_url'] = post_file("prints/{$print['id']}/walking-paper-{$print['id']}.pdf", $pdf_content, 'application/pdf');
        
        if(PEAR::isError($print['pdf_url']))
            die_with_code(500, "{$print['pdf_url']->message}\n{$q}\n");
        
        unlink($map_filename);
        unlink($code_filename);
        
        return $print;
    }
    
    if($zoom && $north && $south && $east && $west)
    {
        $dbh->query('START TRANSACTION');
        
        $print = add_print($dbh, $user['id']);
        
        $print['north'] = $north;
        $print['south'] = $south;
        $print['east'] = $east;
        $print['west'] = $west;
        $print['zoom'] = $zoom;
        $print['orientation'] = $orientation;
        $print['provider'] = $provider;
        
        list($print['country_name'], $print['country_woeid'],
             $print['region_name'], $print['region_woeid'],
             $print['place_name'], $print['place_woeid'])
         = latlon_placeinfo(($north + $south) / 2, ($west + $east) / 2, $zoom - 1);

        $print = compose_map($print);

        set_print($dbh, $print);
        
        $dbh->query('COMMIT');
        
        $print_url = 'http://'.get_domain_name().get_base_dir().'/print.php?id='.urlencode($print['id']);
        header("Location: {$print_url}");
    }
    
    /**** ... ****/
    
    
    $sm = get_smarty_instance();
    $sm->assign('url', $url);
    $sm->assign('width', $width);
    $sm->assign('height', $height);
    $sm->assign('language', $language);
    
    header("Content-Type: text/html; charset=UTF-8");
    print $sm->fetch("compose.html.tpl");

    print_r($map_headers);
    print_r($code_headers);

?>
