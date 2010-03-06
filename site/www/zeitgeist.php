<?php
   /**
    * Statistics display page, with information about a variety
    * of usage numbers for this installation of Walking Papers.
    */

    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'../lib');
    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'/usr/home/migurski/pear/lib');
    require_once 'init.php';
    require_once 'data.php';
    
    list($user_id, $language) = read_userdata($_COOKIE['visitor'], $_SERVER['HTTP_ACCEPT_LANGUAGE']);

    /**** ... ****/
    
    $dbh =& get_db_connection();
    
    if($user_id)
        $user = get_user($dbh, $user_id);

    if($user)
        setcookie('visitor', write_userdata($user['id'], $language), time() + 86400 * 31);
    


    $res = $dbh->query('SELECT COUNT(*) FROM prints WHERE created > NOW() - INTERVAL 1 MONTH');
    
    if(PEAR::isError($res)) 
        die_with_code(500, "{$res->message}\n");

    $print_count = end($res->fetchRow());
    


    $res = $dbh->query('SELECT COUNT(*)
                        FROM scans
                        WHERE last_step = '.STEP_FINISHED);
    
    if(PEAR::isError($res)) 
        die_with_code(500, "{$res->message}\n");

    $scan_count = end($res->fetchRow());
    
    
    
    $hemisphere_count = array('northern' => 0, 'southern' => 0, 'eastern' => 0, 'western' => 0);
    $orientation_count = array('landscape' => 0, 'portrait' => 0);
    
    $res = $dbh->query('SELECT (north + south) / 2 AS latitude,
                               (east + west) / 2 AS longitude,
                               orientation
                        FROM prints
                        WHERE created > NOW() - INTERVAL 1 MONTH');

    if(PEAR::isError($res)) 
        die_with_code(500, "{$res->message}\n");

    while($row = $res->fetchRow(DB_FETCHMODE_ASSOC))
    {
        $hemisphere_count['northern'] += ($row['latitude'] > 0 ? 1 : 0);
        $hemisphere_count['southern'] += ($row['latitude'] < 0 ? 1 : 0);
        $hemisphere_count['eastern'] += ($row['longitude'] > 0 ? 1 : 0);
        $hemisphere_count['western'] += ($row['longitude'] < 0 ? 1 : 0);
        $orientation_count[$row['orientation']] += 1;
    }

    $hemisphere_percent = array(
        'northern' => round(100 * $hemisphere_count['northern'] / ($hemisphere_count['northern'] + $hemisphere_count['southern'])),
        'southern' => round(100 * $hemisphere_count['southern'] / ($hemisphere_count['northern'] + $hemisphere_count['southern'])),
        'eastern' => round(100 * $hemisphere_count['eastern'] / ($hemisphere_count['eastern'] + $hemisphere_count['western'])),
        'western' => round(100 * $hemisphere_count['western'] / ($hemisphere_count['eastern'] + $hemisphere_count['western']))
    );

    $orientation_percent = array(
        'landscape' => round(100 * $orientation_count['landscape'] / ($orientation_count['landscape'] + $orientation_count['portrait'])),
        'portrait' => round(100 * $orientation_count['portrait'] / ($orientation_count['landscape'] + $orientation_count['portrait']))
    );
    
    
    
    $zooms = array(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    
    if(in_array('zoom', array_keys(table_columns($dbh, 'prints'))))
    {
        $res = $dbh->query('SELECT zoom, count(*) AS prints
                            FROM prints
                            WHERE zoom
                              AND created > NOW() - INTERVAL 1 MONTH
                            GROUP BY zoom
                            ORDER BY zoom');
    
        if(PEAR::isError($res)) 
            die_with_code(500, "{$res->message}\n");
    
        while($row = $res->fetchRow(DB_FETCHMODE_ASSOC))
            $zooms[$row['zoom']] = $row['prints'];
    }
    
    
    
    $country_names = array();
    $country_counts = array();
    $country_percents = array();
    
    if(in_array('country_woeid', array_keys(table_columns($dbh, 'prints'))))
    {
        $res = $dbh->query('SELECT country_woeid, country_name, COUNT(*) AS print_count
                            FROM prints
                            WHERE country_woeid
                              AND created > NOW() - INTERVAL 1 MONTH
                            GROUP BY country_woeid
                            ORDER BY print_count DESC, created DESC');
    
        if(PEAR::isError($res)) 
            die_with_code(500, "{$res->message}\n");
    
        $total = 0;
        
        while($row = $res->fetchRow(DB_FETCHMODE_ASSOC))
        {
            $total += $row['print_count'];
        
            if($country_counts[$row['country_woeid']]) {
                $country_counts[$row['country_woeid']] += $row['print_count'];

            } else {
                $country_names[$row['country_woeid']] = $row['country_name'];
                $country_counts[$row['country_woeid']] = $row['print_count'];
            }
            
            // the pie chart is small
            if(count($country_names) == 10)
                break;
        }
        
        foreach($country_counts as $woeid => $count)
            $country_percents[$woeid] = round(100 * $count / $total);
    }
    
    
    
    $scan_states = array('progress' => 0, 'finished' => 0, 'failed' => 0);
    $total_scans = 0;
    
    $res = $dbh->query('SELECT last_step, COUNT(*) AS scans
                        FROM scans
                        WHERE last_step != 0
                          AND created > NOW() - INTERVAL 1 MONTH
                        GROUP BY last_step');

    if(PEAR::isError($res)) 
        die_with_code(500, "{$res->message}\n");

    while($row = $res->fetchRow(DB_FETCHMODE_ASSOC))
    {
        if(in_array($row['last_step'], array(STEP_FINISHED))) {
            $scan_states['finished'] += $row['scans'];

        } elseif(in_array($row['last_step'], array(STEP_FATAL_ERROR, STEP_FATAL_QRCODE_ERROR))) {
            $scan_states['failed'] += $row['scans'];

        } else {
            $scan_states['progress'] += $row['scans'];
        }
        
        $total_scans += $row['scans'];
    }
    
    if($total_scans)
    {
        $scan_states['finished'] = round(100 * $scan_states['finished'] / $total_scans);
        $scan_states['progress'] = round(100 * $scan_states['progress'] / $total_scans);
        $scan_states['failed'] = round(100 * $scan_states['failed'] / $total_scans);
    }
    


    $sm = get_smarty_instance();
    //$sm->assign('print_count', $print_count);
    //$sm->assign('scan_count', $scan_count);
    $sm->assign('print_percent', round(100 * $print_count / ($print_count + $scan_count)));
    $sm->assign('scan_percent', round(100 * $scan_count / ($print_count + $scan_count)));
    //$sm->assign('hemisphere_count', $hemisphere_count);
    $sm->assign('hemisphere_percent', $hemisphere_percent);
    //$sm->assign('orientation_count', $orientation_count);
    $sm->assign('orientation_percent', $orientation_percent);
    $sm->assign('country_names', $country_names);
    //$sm->assign('country_counts', $country_counts);
    $sm->assign('country_percents', $country_percents);
    $sm->assign('scan_states', $scan_states);
    $sm->assign('zooms', $zooms);
    $sm->assign('language', $language);
    
    header("Content-Type: text/html; charset=UTF-8");
    print $sm->fetch("zeitgeist.html.tpl");

?>
