<?php
   /**
    * New print composition endpoint.
    *
    * POST vars include bounding box, print orientation, and tile provider.
    *
    * Redirects to print.php?id=* on successful composition.
    */

    require_once '../lib/lib.everything.php';
    
    $language = $_SERVER['HTTP_ACCEPT_LANGUAGE'];
        
    enforce_master_on_off_switch($language);

    $source = $_POST['source'];
    
    $north = is_numeric($_POST['north']) ? floatval($_POST['north']) : null;
    $south = is_numeric($_POST['south']) ? floatval($_POST['south']) : null;
    $east = is_numeric($_POST['east']) ? floatval($_POST['east']) : null;
    $west = is_numeric($_POST['west']) ? floatval($_POST['west']) : null;
    $zoom = is_numeric($_POST['zoom']) ? intval($_POST['zoom']) : null;
    $paper = $_POST['paper'] ? $_POST['paper'] : null;
    $provider = $_POST['provider'] ? $_POST['provider'] : null;
    $layout = $_POST['layout'] ? $_POST['layout'] : null;
    
    switch(strtolower($_POST['grid']))
    {
        case 'utm':
        case 'mgrs':
            $provider .= sprintf(",http://tiles.teczno.com/%s/{Z}/{X}/{Y}.png", strtolower($_POST['grid']));
    }
    
    session_start();
    $dbh =& get_db_connection();
    remember_user($dbh);

    if($source == 'upload' && ADVANCED_COMPOSE_FORM)
    {
        $dbh->query('START TRANSACTION');
        
        $print = add_print($dbh, $user['id']);
        
        $geotiff_filename = str_replace(' ', '-', $_FILES['file']['name']);
        $geotiff_contents = file_get_contents($_FILES['file']['tmp_name']);
        $geotiff_mimetype = trim(`file -bi {$_FILES['file']['tmp_name']}`);
        
        $print['geotiff_url'] = post_file("prints/{$print['id']}/{$geotiff_filename}", $geotiff_contents, $geotiff_mimetype);
        
        if(preg_match('/\b(letter|a4|a3)\b/', $paper, $parts)) {
            $print['paper_size'] = $parts[1];
            
        } else {
            die_with_code(500, "Give us a meaningful paper, not \"{$print['paper']}\"\n");
        }

        set_print($dbh, $print);
        
        $message = array('print_id' => $print['id'],
                         'paper_size' => $print['paper_size'],
                         'geotiff_url' => $print['geotiff_url']);
        
        add_message($dbh, json_encode($message));
        
        $dbh->query('COMMIT');
        
        $print_url = 'http://'.get_domain_name().get_base_dir().'/print.php?id='.urlencode($print['id']);
        header("Location: {$print_url}");
        
        exit();
    }
    
    if($source == 'bounds')
    {
        $dbh->query('START TRANSACTION');
        
        $print = add_print($dbh, $user['id']);
        
        if(preg_match('/^(portrait|landscape)-(letter|a4|a3)$/', $paper, $parts)) {
            $orientation = $parts[1];
            $paper_size = $parts[2];
            
        } else {
            die_with_code(500, "Give us a meaningful paper, not \"{$print['paper']}\"\n");
        }

        $print['north'] = $north;
        $print['south'] = $south;
        $print['east'] = $east;
        $print['west'] = $west;
        $print['zoom'] = $zoom;
        $print['paper'] = $paper;
        $print['provider'] = $provider;
        $print['orientation'] = $orientation;
        $print['paper_size'] = $paper_size;
        $print['layout'] = $layout;

        set_print($dbh, $print);
        
        $message = array('action' => 'compose',
                         'print_id' => $print['id'],
                         'bounds' => array($north, $west, $south, $east),
                         'zoom' => $zoom,
                         'provider' => $provider,
                         'paper_size' => $paper_size,
                         'orientation' => $orientation,
                         'layout' => $layout);
        
        add_message($dbh, json_encode($message));
        
        $dbh->query('COMMIT');
        
        $print_url = 'http://'.get_domain_name().get_base_dir().'/print.php?id='.urlencode($print['id']);
        header("Location: {$print_url}");
        
        exit();
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
