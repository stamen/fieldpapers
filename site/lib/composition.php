<?php
   /**
    * New print composition endpoint.
    *
    * POST vars include bounding box, print orientation, and tile provider.
    *
    * Redirects to print.php?id=* on successful composition.
    */

    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'/usr/home/migurski/pear/lib');
    require_once 'init.php';
    require_once 'data.php';
    
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
    
   /**
    * 
    */
    function get_page_orientation($paper)
    {
        switch($paper)
        {
            case 'portrait-letter':
            case 'portrait-a3':
            case 'portrait-a4':
                return 'P';

            case 'landscape-letter':
            case 'landscape-a3':
            case 'landscape-a4':
                return 'L';
        }
    }
    
   /**
    * 
    */
    function get_page_size($paper)
    {
        switch($paper)
        {
            case 'portrait-letter':
            case 'landscape-letter':
                return 'letter';

            case 'portrait-a3':
            case 'landscape-a3':
                return 'a3';

            case 'portrait-a4':
            case 'landscape-a4':
                return 'a4';
        }
    }
    
    function compose_map($print, $pages)
    {
        $garbage = array();
        $atlas_pages = array();

        if(preg_match('/^(portrait|landscape)-(letter|a4|a3)$/', $print['paper'], $parts)) {
            $print['orientation'] = $parts[1];
            $print['paper_size'] = $parts[2];
            
        } else {
            die_with_code(500, "Give us a meaningful paper, not \"{$print['paper']}\"\n");
        }
        
        $print_url = 'http://'.get_domain_name().get_base_dir().'/print.php?id='.urlencode($print['id']);
        
        $pdf = new FPDF(get_page_orientation($print['paper']), 'pt', get_page_size($print['paper']));
        
        foreach($pages as $page)
        {
            if($page['part']) {
                $page_url = "{$print_url}/{$page['part']}";
                $atlas_pages[] = $page;
            
            } else {
                $page_url = $print_url;
            }
    
            $pdf->addPage();
            
            $icon_filename = realpath(dirname(__FILE__).'/../lib/print/icon.png');
            $pdf->image($icon_filename, 35.99, 42.87, 19.2, 25.6);
            
            $hand_filename = realpath(dirname(__FILE__).'/../lib/print/Hand.png');
            $pdf->image($hand_filename, $pdf->w - 96, 30, 66, 48);
            
            $map_filename = tempnam(TMP_DIR, 'composed-map-');
            $garbage[] = $map_filename;
            
            if($fh = @fopen($map_filename, 'w'))
            {
                $req = new HTTP_Request($page['href']);
                $req->sendRequest();
                @fwrite($fh, $req->getResponseBody());
                @fclose($fh);
            }
            
            $pdf->image($map_filename, 36, 72, $pdf->w - 72, $pdf->h - 108, 'jpg');
            
            $pdf->setFont('Helvetica', 'B', 24);
            $pdf->text(62.61, 68.49, 'Walking Papers');
            
            $pdf->setFillColor(0xFF);
            $pdf->rect(35, $pdf->h - 63, 200, 28, 'F');
            
            $ccbysa_filename = realpath(dirname(__FILE__).'/../lib/print/CCBYSA.png');
            $pdf->image($ccbysa_filename, 30, $pdf->h - 60, 67, 30);
    
            $pdf->setFont('Helvetica', '', 9);
            $pdf->text($pdf->w - 358, 57.74, 'Help improve OpenStreetMap by drawing on this map, then visit');
            $pdf->text($pdf->w - 358, 68.74, $page_url);
            $pdf->text(99, $pdf->h - 47.5, 'Map data ©2010 CC-BY-SA');
            $pdf->text(99, $pdf->h - 36.5, 'OpenStreetMap.org contributors');
    
            $size = 64;
            $pad = 8;
            
            $pdf->setFillColor(0xFF);
            $pdf->rect($pdf->w - 36 - $size - $pad, $pdf->h - 36 - $size - $pad, $size + $pad * 2, $size + $pad * 2, 'F');
            
            //$page_url .= sprintf('#n=%.6f,w=%.6f,s=%.6f,e=%.6f', $print['north'], $print['west'], $print['south'], $print['east']);
            
            $req = new HTTP_Request('http://chart.apis.google.com/chart?chs=264x264&cht=qr&chld=Q|0');
            $req->addQueryString('chl', $page_url);
            $res = $req->sendRequest();
            
            if(PEAR::isError($res))
                die_with_code(500, "{$res->message}\n{$q}\n");
            
            $code_img = imagecreatefromstring($req->getResponseBody());
            $code_filename = tempnam(TMP_DIR, 'composed-code-');
            imagepng($code_img, $code_filename);
            $pdf->image($code_filename, $pdf->w - 36 - $size, $pdf->h - 36 - $size, $size, $size, 'png');

            $garbage[] = $code_filename;
        }
        
        $pdf_content = $pdf->output('', 'S');
        
        // post the PDF
        $url = new Net_URL($print['pdf_url']);
        $print['pdf_url'] = post_file("prints/{$print['id']}/walking-paper-{$print['id']}.pdf", $pdf_content, 'application/pdf');
        
        $print['atlas_pages'] = json_encode($atlas_pages);
        
        if(PEAR::isError($print['pdf_url']))
            die_with_code(500, "{$print['pdf_url']->message}\n{$q}\n");
        
        foreach($garbage as $filename)
            unlink($filename);
        
        return $print;
    }

?>
