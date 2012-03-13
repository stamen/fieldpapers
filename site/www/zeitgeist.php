<?php

    require_once '../lib/lib.everything.php';
    
    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);
    
    $context = default_context();

    /**** ... ****/

    $res = $context->db->query('SELECT COUNT(*) FROM prints WHERE created > NOW() - INTERVAL 1 MONTH');
    
    if(PEAR::isError($res)) 
        die_with_code(500, "{$res->message}\n");

    $print_count = end($res->fetchRow());
    


    $res = $context->db->query('SELECT COUNT(*)
                                FROM scans
                                WHERE decoded');
    
    if(PEAR::isError($res)) 
        die_with_code(500, "{$res->message}\n");

    $scan_count = end($res->fetchRow());
    
    
    
    $hemisphere_count = array('northern' => 0, 'southern' => 0, 'eastern' => 0, 'western' => 0);
    $orientation_count = array('landscape' => 0, 'portrait' => 0);
    
    $res = $context->db->query('SELECT (north + south) / 2 AS latitude,
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
    
    if(in_array('zoom', array_keys(table_columns($context->db, 'prints'))))
    {
        $res = $context->db->query('SELECT zoom, count(*) AS prints
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
    
    if(in_array('country_woeid', array_keys(table_columns($context->db, 'prints'))))
    {
        $res = $context->db->query('SELECT country_woeid, country_name, COUNT(*) AS print_count
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
    
    $res = $context->db->query('SELECT last_step, COUNT(*) AS scans
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
    


    //$context->sm->assign('print_count', $print_count);
    //$context->sm->assign('scan_count', $scan_count);
    $context->sm->assign('print_percent', round(100 * $print_count / ($print_count + $scan_count)));
    $context->sm->assign('scan_percent', round(100 * $scan_count / ($print_count + $scan_count)));
    //$context->sm->assign('hemisphere_count', $hemisphere_count);
    $context->sm->assign('hemisphere_percent', $hemisphere_percent);
    //$context->sm->assign('orientation_count', $orientation_count);
    $context->sm->assign('orientation_percent', $orientation_percent);
    $context->sm->assign('country_names', $country_names);
    //$context->sm->assign('country_counts', $country_counts);
    $context->sm->assign('country_percents', $country_percents);
    $context->sm->assign('scan_states', $scan_states);
    $context->sm->assign('zooms', $zooms);
    $context->sm->assign('language', $language);
    
    header("Content-Type: text/html; charset=UTF-8");
    print $context->sm->fetch("zeitgeist.html.tpl");

?>
