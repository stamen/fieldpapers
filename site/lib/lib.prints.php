<?php

    function add_print(&$dbh, $user_id)
    {
        while(true)
        {
            $print_id = generate_id();
            
            $q = sprintf('INSERT INTO prints
                          SET id = %s, user_id = %s',
                         $dbh->quoteSmart($print_id),
                         $dbh->quoteSmart($user_id));

            error_log(preg_replace('/\s+/', ' ', $q));
    
            $res = $dbh->query($q);
            
            if(PEAR::isError($res)) 
            {
                if($res->getCode() == DB_ERROR_ALREADY_EXISTS)
                    continue;
    
                die_with_code(500, "{$res->message}\n{$q}\n");
            }
            
            return get_print($dbh, $print_id);
        }
    }
    
    function get_prints(&$dbh, $user, $args, $page)
    {
        list($count, $offset, $perpage, $page) = get_pagination($page);
        
        $where_clauses = array(
            'composed',
        );

        if ($user['id']) {
            $where_clauses[] = sprintf('(private = 0 OR (private = 1 AND user_id = %s))', $dbh->quoteSmart($user['id']));
        } else {
            $where_clauses[] = 'private = 0';
        }
        
        if(isset($args['date']) && $time = strtotime($args['date']))
        {
            $start = date('Y-m-d 00:00:00', $time);
            $end = date('Y-m-d 23:59:59', $time);
            
            $where_clauses[] = sprintf('(created BETWEEN "%s" AND "%s")', $start, $end);
        }
        
        if(isset($args['month']) && $time = strtotime("{$args['month']}-01"))
        {
            $start = date('Y-m-d 00:00:00', $time);
            $end = date('Y-m-d 23:59:59', $time + 86400 * intval(date('t', $time)));
            
            $where_clauses[] = sprintf('(created BETWEEN "%s" AND "%s")', $start, $end);
        }
        
        if(isset($args['place']))
        {
            $woeid_clauses = array(
                sprintf('place_woeid = %d', $args['place']),
                sprintf('region_woeid = %d', $args['place']),
                sprintf('country_woeid = %d', $args['place'])
                );
        
            $where_clauses[] = '(' . join(' OR ', $woeid_clauses) . ')';
        }
        
        if(isset($args['user']))
        {
            $where_clauses[] = sprintf('(user_id = %s)', $dbh->quoteSmart($args['user']));
        }
        
        $q = sprintf("SELECT paper_size, orientation, provider, private,
                             pdf_url, preview_url, geotiff_url,
                             id, title, north, south, east, west, zoom,
                             (north + south) / 2 AS latitude,
                             (east + west) / 2 AS longitude,
                             UNIX_TIMESTAMP(created) AS created,
                             UNIX_TIMESTAMP(composed) AS composed,
                             UNIX_TIMESTAMP(NOW()) - UNIX_TIMESTAMP(created) AS age,
                             country_name, country_woeid, region_name, region_woeid, place_name, place_woeid,
                             user_id, progress
                      FROM prints
                      WHERE %s
                      ORDER BY created DESC
                      LIMIT %d OFFSET %d",

                     join(' AND ', $where_clauses),
                     $count, $offset);
    
        $res = $dbh->query($q);
        
        if(PEAR::isError($res)) 
            die_with_code(500, "{$res->message}\n{$q}\n");

        $rows = array();
        
        while($row = $res->fetchRow(DB_FETCHMODE_ASSOC))
        {
            // TODO: ditch special-case for provider
            if(empty($row['provider']))
                $row['provider'] = reset(reset(get_map_providers()));

            // TODO: ditch special-case for pdf_url
            if(empty($row['pdf_url']) && S3_BUCKET_ID)
                $row['pdf_url'] = sprintf('http://%s.s3.amazonaws.com/prints/%s/walking-paper-%s.pdf', S3_BUCKET_ID, $row['id'], $row['id']);

            // TODO: ditch special-case for preview_url
            if(empty($row['preview_url']) && S3_BUCKET_ID)
                $row['preview_url'] = sprintf('http://%s.s3.amazonaws.com/prints/%s/preview.png', S3_BUCKET_ID, $row['id']);

            $rows[] = $row;
        }
        
        return $rows;
    }
    
    function get_print(&$dbh, $print_id)
    {
        $atlas_part = false;
    
        if(preg_match('#^(\w+)/(\w+)$#', $print_id, $m))
            list($print_id, $page_number) = array($m[1], $m[2]);
    
        $q = "SELECT layout, atlas_pages,
                     paper_size, orientation, provider, private,
                     pdf_url, preview_url, geotiff_url,
                     id, title, text, form_id, north, south, east, west, zoom,
                     (north + south) / 2 AS latitude,
                     (east + west) / 2 AS longitude,
                     UNIX_TIMESTAMP(created) AS created,
                     UNIX_TIMESTAMP(composed) AS composed,
                     UNIX_TIMESTAMP(NOW()) - UNIX_TIMESTAMP(created) AS age,
                     country_name, country_woeid, region_name, region_woeid, place_name, place_woeid,
                     user_id, progress
              FROM prints
              WHERE id = ?";
    
        $res = $dbh->query($q, $print_id);
        
        if(PEAR::isError($res)) 
            die_with_code(500, "{$res->message}\n{$q}\n");

        $row = $res->fetchRow(DB_FETCHMODE_ASSOC);

        if (empty($row)) {
            return null;
        }
        
        // TODO: ditch special-case for provider
        if(empty($row['provider']))
            $row['provider'] = reset(reset(get_map_providers()));

        // TODO: ditch special-case for pdf_url
        if(empty($row['pdf_url']) && S3_BUCKET_ID)
            $row['pdf_url'] = sprintf('http://%s.s3.amazonaws.com/prints/%s/walking-paper-%s.pdf', S3_BUCKET_ID, $row['id'], $row['id']);

        // TODO: ditch special-case for preview_url
        if(empty($row['preview_url']) && S3_BUCKET_ID)
            $row['preview_url'] = sprintf('http://%s.s3.amazonaws.com/prints/%s/preview.png', S3_BUCKET_ID, $row['id']);
        
        if($page_number)
        {
            $row['selected_page'] = get_print_page($dbh, $print_id, $page_number);
        }
        
        return $row;
    }
    
    function set_print(&$dbh, $print)
    {
        $old_print = get_print($dbh, $print['id']);
        
        if(!$old_print)
            return false;

        $update_clauses = array();

        $field_names = array(
            'title', 'text', 'north', 'south', 'east', 'west', 'zoom', 'paper_size',
            'orientation', 'layout', 'provider', 'pdf_url', 'preview_url',
            'geotiff_url', 'atlas_pages', 'form_id', 'user_id',
            'country_name', 'country_woeid', 'region_name', 'region_woeid',
            'place_name', 'place_woeid', 'progress', 'private',
            );

        foreach($field_names as $field)
            if(!is_null($print[$field]))
                if($print[$field] != $old_print[$field])
                    $update_clauses[] = sprintf('%s = %s', $field, $dbh->quoteSmart($print[$field]));

        if(empty($update_clauses)) {
            error_log("skipping print {$print['id']} update since there's nothing to change");

        } else {
            $update_clauses = join(', ', $update_clauses);
            
            $q = "UPDATE prints
                  SET {$update_clauses}
                  WHERE id = ".$dbh->quoteSmart($print['id']);
    
            error_log(preg_replace('/\s+/', ' ', $q));
    
            $res = $dbh->query($q);
            
            if(PEAR::isError($res))
                die_with_code(500, "{$res->message}\n{$q}\n");
        }

        return get_print($dbh, $print['id']);
    }
    
    function finish_print(&$dbh, $print_id)
    {
        $q = sprintf('UPDATE pages SET composed = NOW() WHERE print_id = %s',
                     $dbh->quoteSmart($print_id));

        error_log(preg_replace('/\s+/', ' ', $q));

        $res = $dbh->query($q);
        
        if(PEAR::isError($res))
            die_with_code(500, "{$res->message}\n{$q}\n");

        $q = sprintf('UPDATE prints SET composed = NOW() WHERE id = %s',
                     $dbh->quoteSmart($print_id));

        error_log(preg_replace('/\s+/', ' ', $q));

        $res = $dbh->query($q);
        
        if(PEAR::isError($res))
            die_with_code(500, "{$res->message}\n{$q}\n");
    }
    
    function add_print_page(&$dbh, $print_id, $page_number)
    {
        $q = sprintf('INSERT INTO pages
                      SET print_id = %s, page_number = %s',
                     $dbh->quoteSmart($print_id),
                     $dbh->quoteSmart($page_number));

        error_log(preg_replace('/\s+/', ' ', $q));

        $res = $dbh->query($q);
        
        if(PEAR::isError($res)) 
        {
            die_with_code(500, "{$res->message}\n{$q}\n");
        }
        
        return get_print_page($dbh, $print_id, $page_number);
    }
    
    function get_print_pages(&$dbh, $print_id)
    {
        $q = sprintf("SELECT print_id, page_number, text,
                             provider, preview_url,
                             north, south, east, west, zoom,
                             (north + south) / 2 AS latitude,
                             (east + west) / 2 AS longitude,
                             UNIX_TIMESTAMP(created) AS created,
                             UNIX_TIMESTAMP(NOW()) - UNIX_TIMESTAMP(created) AS age,
                             country_name, country_woeid, region_name, region_woeid, place_name, place_woeid,
                             user_id
                      FROM pages
                      WHERE print_id = %s",
                     $dbh->quoteSmart($print_id));
    
        $res = $dbh->query($q);
        
        if(PEAR::isError($res)) 
            die_with_code(500, "{$res->message}\n{$q}\n");
            
            
            
        $rows = array();
        
        while($row = $res->fetchRow(DB_FETCHMODE_ASSOC))
        {            
            $rows[] = $row;
        }
        
        return $rows;
    }
    
    function get_print_page(&$dbh, $print_id, $page_number)
    {
        $q = sprintf("SELECT print_id, page_number, text,
                             provider, preview_url,
                             north, south, east, west, zoom,
                             (north + south) / 2 AS latitude,
                             (east + west) / 2 AS longitude,
                             UNIX_TIMESTAMP(created) AS created,
                             UNIX_TIMESTAMP(NOW()) - UNIX_TIMESTAMP(created) AS age,
                             country_name, country_woeid, region_name, region_woeid, place_name, place_woeid,
                             user_id
                      FROM pages
                      WHERE print_id = %s
                        AND page_number = %s",
                     $dbh->quoteSmart($print_id),
                     $dbh->quoteSmart($page_number));
    
        $res = $dbh->query($q);
        
        if(PEAR::isError($res)) 
            die_with_code(500, "{$res->message}\n{$q}\n");

        $row = $res->fetchRow(DB_FETCHMODE_ASSOC);
        
        return $row;
    }
    
    function set_print_page(&$dbh, $page)
    {
        $old_page = get_print_page($dbh, $page['print_id'], $page['page_number']);
        
        if(!$old_page)
            return false;

        $update_clauses = array();

        foreach(array('north', 'south', 'east', 'west', 'zoom', 'provider', 'preview_url', 'user_id', 'country_name', 'country_woeid', 'region_name', 'region_woeid', 'place_name', 'place_woeid', 'text') as $field)
            if(!is_null($page[$field]))
                if($page[$field] != $old_page[$field])
                    $update_clauses[] = sprintf('%s = %s', $field, $dbh->quoteSmart($page[$field]));

        if(empty($update_clauses)) {
            error_log("skipping page {$page['print_id']}/{$page['page_number']} update since there's nothing to change");

        } else {
            $update_clauses = join(', ', $update_clauses);
            
            $q = sprintf('UPDATE pages SET %s
                          WHERE print_id = %s
                            AND page_number = %s',
                         $update_clauses,
                         $dbh->quoteSmart($page['print_id']),
                         $dbh->quoteSmart($page['page_number']));
            
            error_log(preg_replace('/\s+/', ' ', $q));
    
            $res = $dbh->query($q);
            
            if(PEAR::isError($res))
                die_with_code(500, "{$res->message}\n{$q}\n");
        }

        return get_print_page($dbh, $page['print_id'], $page['page_number']);
    }
    
    function get_print_activity(&$dbh, $print_id, $group_notes)
    {
        $print = get_print($dbh, $print_id);
        $pages = get_print_pages($dbh, $print_id);
        $print['page_count'] = count($pages);
        $print['pages'] = $pages;
        
        $users = array();
        $user_id = $print['user_id'];
        
        if ($users[$user_id] == null && $user_id != null)
            $users[$user_id] = get_user($dbh, $user_id);
        
        $print['user_name'] = $users[$user_id]['name'];
        
        if($scans = get_scans($dbh, array('print' => $print['id']), 9999))
        {
            $note_args = array('scans' => array());
            
            foreach($scans as $i => $scan)
            {
                $note_args['scans'][] = $scan['id'];
                $user_id = $scan['user_id'];
                
                if($users[$user_id] == null && $user_id != null)
                    $users[$user_id] = get_user($dbh, $user_id);
                
                $scans[$i]['user_name'] = $users[$user_id]['name'];
                $scans[$i]['page'] = get_print_page($dbh, $scan['print_id'], $scan['print_page_number']);
            }
            
            $notes = get_scan_notes($dbh, $note_args);
            
            foreach($notes as $i => $note)
            {
                $notes[$i]['scan'] = $scan;
                $user_id = $note['user_id'];
                
                if(is_null($users[$user_id]))
                    $users[$user_id] = get_user($dbh, $user_id);
                
                $notes[$i]['user_name'] = $users[$user_id]['name'];
            }
    
        } else {
            $notes = array();
        }
        
        $activity = array(array('type' => 'print', 'print' => $print));
        $times = array($print['created']);
    
        foreach($scans as $scan)
        {
            $activity[] = array('type' => 'scan', 'scan' => $scan);
            $times[] = $scan['created'];
        }
            
        foreach($notes as $note)
        {
            $activity[] = array('type' => 'note', 'note' => $note);
            $times[] = $note['created'];
        }
        
        array_multisort($times, SORT_ASC, $activity);
        
        if($group_notes)
        {
            $scan_note_indexes = array();
            
            // group notes into lists by scan, ending on the latest
            for($i = count($activity) - 1; $i >= 0; $i--)
            {
                if($activity[$i]['type'] != 'note')
                    continue;
                
                $note = $activity[$i]['note'];
                $group = "{$note['scan']['id']}-{$note['user_name']}";
                
                if(isset($scan_note_indexes[$group])) {
                    //
                    // Add this note to the existing array in the activity list.
                    //
                    $index = $scan_note_indexes[$group];
                    array_unshift($activity[$index]['notes'], $note);
                    $activity[$i] = array('type' => false);
                
                } else {
                    //
                    // Most-recent note by this person on this scan;
                    // prepare an array of notes in the activity list.
                    //
                    $scan_note_indexes[$group] = $i;
                    $activity[$i] = array('type' => 'notes', 'notes' => array($note));
                }
            }
        }
        
        return $activity;
    }
    
    function print_to_geojson($print, $pages)
    {
        $geojson = array(
            'type' => 'FeatureCollection',
            'properties' => array(
                'paper_size' => $print['paper_size'],
                'orientation' => $print['orientation'],
                'layout' => $print['layout']
            ),
            'features' => array()
        );
        
        foreach($pages as $page)
        {
            $north = floatval($page['north']);
            $south = floatval($page['south']);
            $west = floatval($page['west']);
            $east = floatval($page['east']);
        
            $feature = array(
                'type' => 'Feature',
                'properties' => array('provider' => $page['provider'], 'zoom' => intval($page['zoom'])),
                'geometry' => array(
                    'type' => 'Polygon',
                    'coordinates' => array(array(
                        array($west, $north), array($east, $north),
                        array($east, $south), array($west, $south),
                        array($west, $north)
                    ))
                )
            );
            
            $geojson['features'][] = $feature;
        }
        
        return json_encode($geojson);
    }
    
    function print_to_geojson_feature($print)
    {
        $feature = array(
            'type' => 'Feature',
            'properties' => array(
                'type' => 'atlas',
                'person_href' => null,
                'href' => 'http://'.get_domain_name().get_base_dir().'/atlas.php?id='.urlencode($print['id']),
                'created' => date('r', $print['created'])
            ),
            'geometry' => array(
                'type' => 'MultiPolygon',
                'coordinates' => null
            )
        );
        
        $polys = array();
        
        foreach($print['pages'] as $page)
        {
            $north = floatval($page['north']);
            $south = floatval($page['south']);
            $east = floatval($page['east']);
            $west = floatval($page['west']);
            
            $polys[] = array(array(
                array($west, $south),
                array($west, $north),
                array($east, $north),
                array($east, $south),
                array($west, $south)
            ));
        }
        
        $feature['geometry']['coordinates'] = $polys;
        
        if($print['user_name'])
            $feature['properties']['person_href'] = 'http://'.get_domain_name().get_base_dir().'/atlases.php?user='.urlencode($print['user_id']);
        
        return $feature;
    }

    function print_to_csv_row($print)
    {
        $row = array(
            'type' => 'atlas',
            'href' => 'http://'.get_domain_name().get_base_dir().'/atlas.php?id='.urlencode($print['id']),
            'created' => '"'.date('r', $print['created']).'"',
            'person_href' => '',
            'geometry' => '',
            'atlas_page_href' => '',
            'snapshot_href' => '',
            'note' => ''
        );
        
        if($print['user_name'])
            $row['person_href'] = 'http://'.get_domain_name().get_base_dir().'/atlases.php?user='.urlencode($print['user_id']);

        $polys = array();
        
        foreach($print['pages'] as $page)
        {
            $north = floatval($page['north']);
            $south = floatval($page['south']);
            $east = floatval($page['east']);
            $west = floatval($page['west']);
            
            $polys[] = sprintf('((%.6f %.6f,%.6f %.6f,%.6f %.6f,%.6f %.6f,%.6f %.6f))',
                               $west, $south, $west, $north, $east, $north, $east, $south, $west, $south);
        }
        
        $row['geometry'] = sprintf('"MULTIPOLYGON(%s)"', join(', ', $polys));
        
        return join(',', array_values($row));
    }

?>
