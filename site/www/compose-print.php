<?php

    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.dirname(__FILE__).'/../lib');

    require_once 'init.php';
    require_once 'data.php';
    require_once 'lib.compose.php';
    
    $is_json = false;

    foreach(getallheaders() as $header => $value)
    {
        if(strtolower($header) == 'content-type')
        {
            $is_json = preg_match('#\b(text|application)/json\b#i', $value);
        }
    }
    
    if($_SERVER['REQUEST_METHOD'] == 'POST')
    {
        $dbh =& get_db_connection();
        $dbh->query('START TRANSACTION');
        
        if($is_json) {
            $json = json_decode(file_get_contents('php://input'), true);
            compose_from_geojson($dbh, file_get_contents('php://input'));

        } else {
            $print = add_print($dbh, 'nobody');
            $page = add_print_page($dbh, $print['id'], 1);
            
            $paper = $_POST['paper'] ? $_POST['paper'] : null;
            
            if(preg_match('/^(portrait|landscape)-(letter|a4|a3)$/', $paper, $parts)) {
                $print['orientation'] = $parts[1];
                $print['paper_size'] = $parts[2];
                
            } else {
                die_with_code(500, "Give us a meaningful paper, not \"{$print['paper']}\"\n");
            }
            
            $print['north'] = is_numeric($_POST['north']) ? floatval($_POST['north']) : null;
            $print['south'] = is_numeric($_POST['south']) ? floatval($_POST['south']) : null;
            $print['east'] = is_numeric($_POST['east']) ? floatval($_POST['east']) : null;
            $print['west'] = is_numeric($_POST['west']) ? floatval($_POST['west']) : null;
            $print['zoom'] = is_numeric($_POST['zoom']) ? intval($_POST['zoom']) : null;
            
            $page['provider'] = $_POST['provider'] ? $_POST['provider'] : null;
            
            $page['north'] = $print['north'];
            $page['south'] = $print['south'];
            $page['east'] = $print['east'];
            $page['west'] = $print['west'];
            $page['zoom'] = $print['zoom'];
            
            $message = array('action' => 'compose print',
                             'paper_size' => $print['paper_size'],
                             'orientation' => $print['orientation'],
                             'pages' => array(
                                array('zoom' => $page['zoom'],
                                      'number' => $page['page_number'],
                                      'provider' => $page['provider'],
                                      'bounds' => array($page['north'], $page['west'], $page['south'], $page['east'])
                                      )
                                )
                             );
            
            set_print($dbh, $print);
            set_print_page($dbh, $page);
            add_message($dbh, json_encode($message));
        }
        
        $dbh->query('COMMIT');
    }
    
?>