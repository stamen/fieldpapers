<?php

    require_once 'data.php';
    
    function add_scan(&$dbh, $user_id)
    {
        while(true)
        {
            $scan_id = generate_id();
            
            $q = sprintf('INSERT INTO scans
                          SET id = %s, user_id = %s',
                         $dbh->quoteSmart($scan_id),
                         $dbh->quoteSmart($user_id));

            error_log(preg_replace('/\s+/', ' ', $q));
    
            $res = $dbh->query($q);
            
            if(PEAR::isError($res)) 
            {
                if($res->getCode() == DB_ERROR_ALREADY_EXISTS)
                    continue;
    
                die_with_code(500, "{$res->message}\n{$q}\n");
            }
            
            return get_scan($dbh, $scan_id);
        }
    }
    
    function get_scan(&$dbh, $scan_id)
    {
        $q = sprintf("SELECT id, print_id, print_page_number, print_href,
                             min_row, min_column, min_zoom,
                             max_row, max_column, max_zoom,
                             description, is_private, will_edit,
                             UNIX_TIMESTAMP(created) AS created,
                             UNIX_TIMESTAMP(decoded) AS decoded,
                             UNIX_TIMESTAMP(NOW()) - UNIX_TIMESTAMP(created) AS age,
                             failed, base_url, uploaded_file,
                             has_geotiff, has_stickers,
                             has_geojpeg, geojpeg_bounds,
                             decoding_json, user_id, progress,
                             place_name, region_name, country_name,
                             place_woeid, region_woeid, country_woeid
                      FROM scans
                      WHERE id = %s",
                     $dbh->quoteSmart($scan_id));
    
        $res = $dbh->query($q);
        
        if(PEAR::isError($res)) 
            die_with_code(500, "{$res->message}\n{$q}\n");

        $scan = $res->fetchRow(DB_FETCHMODE_ASSOC);

        return $scan;
    }
    
    function get_scans(&$dbh, $args, $page, $include_private=false)
    {
        list($count, $offset, $perpage, $page) = get_pagination($page);
    
        $where_clauses = array('decoded');
        
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
        
        if(isset($args['print']))
        {
            $where_clauses[] = sprintf('(print_id = %s)', $dbh->quoteSmart($args['print']));
        }
        
        $q = sprintf("SELECT place_name, place_woeid,
                             region_name, region_woeid,
                             country_name, country_woeid,
                             id, print_id, print_page_number, print_href,
                             min_row, min_column, min_zoom,
                             max_row, max_column, max_zoom,
                             description, is_private, will_edit,
                             UNIX_TIMESTAMP(created) AS created,
                             UNIX_TIMESTAMP(decoded) AS decoded,
                             UNIX_TIMESTAMP(NOW()) - UNIX_TIMESTAMP(created) AS age,
                             failed, base_url, uploaded_file,
                             has_geotiff, has_stickers,
                             has_geojpeg, geojpeg_bounds,
                             user_id, progress
                      FROM scans
                      WHERE %s
                        AND %s
                      ORDER BY created DESC
                      LIMIT %d OFFSET %d",

                     join(' AND ', $where_clauses),
                     ($include_private ? '1' : "is_private='no'"),
                     $count, $offset);
    
        $res = $dbh->query($q);
        
        if(PEAR::isError($res)) 
            die_with_code(500, "{$res->message}\n{$q}\n");

        $rows = array();
        
        while($row = $res->fetchRow(DB_FETCHMODE_ASSOC))
            $rows[] = $row;
        
        return $rows;
    }
    
    function set_scan(&$dbh, $scan)
    {
        $old_scan = get_scan($dbh, $scan['id']);
        
        if(!$old_scan)
            return false;

        $update_clauses = array();

        $field_names = array(
            'print_id', 'print_page_number', 'print_href', 'user_id', 'min_row',
            'min_column', 'min_zoom', 'max_row', 'max_column', 'max_zoom',
            'description', 'is_private', 'will_edit', 'base_url', 'uploaded_file',
            'decoding_json', 'has_geotiff', 'has_geojpeg', 'geojpeg_bounds',
            'has_stickers', 'progress', 'place_name', 'region_name',
            'country_name', 'place_woeid', 'region_woeid', 'country_woeid'
            );

        foreach($field_names as $field)
            if(!is_null($scan[$field]))
                if($scan[$field] != $old_scan[$field] || in_array($field, array('base_url')))
                    $update_clauses[] = sprintf('%s = %s', $field, $dbh->quoteSmart($scan[$field]));

        if(empty($update_clauses)) {
            error_log("skipping scan {$scan['id']} update since there's nothing to change");

        } else {
            $update_clauses = join(', ', $update_clauses);
            
            $q = "UPDATE scans
                  SET {$update_clauses}
                  WHERE id = ".$dbh->quoteSmart($scan['id']);
    
            error_log(preg_replace('/\s+/', ' ', $q));
    
            $res = $dbh->query($q);
            
            if(PEAR::isError($res))
                die_with_code(500, "{$res->message}\n{$q}\n");
        }

        return get_scan($dbh, $scan['id']);
    }
    
    function finish_scan(&$dbh, $scan_id)
    {
        $q = sprintf('UPDATE scans SET decoded = NOW() WHERE id = %s',
                     $dbh->quoteSmart($scan_id));

        error_log(preg_replace('/\s+/', ' ', $q));

        $res = $dbh->query($q);
        
        if(PEAR::isError($res))
            die_with_code(500, "{$res->message}\n{$q}\n");
    }
    
    function fail_scan(&$dbh, $scan_id, $failure=1)
    {
        $q = sprintf('UPDATE scans SET failed = %s WHERE id = %s',
                     $dbh->quoteSmart($failure),
                     $dbh->quoteSmart($scan_id));

        error_log(preg_replace('/\s+/', ' ', $q));

        $res = $dbh->query($q);
        
        if(PEAR::isError($res))
            die_with_code(500, "{$res->message}\n{$q}\n");
    }
    
    function delete_scan(&$dbh, $scan_id)
    {
        $q = sprintf('DELETE FROM scans
                      WHERE id = %s',
                     $dbh->quoteSmart($scan_id));

        error_log(preg_replace('/\s+/', ' ', $q));

        $res = $dbh->query($q);
        
        if(PEAR::isError($res)) 
            die_with_code(500, "{$res->message}\n{$q}\n");

        return true;
    }
    
    function flush_scans(&$dbh, $age)
    {
        $due = time() + 5;
        
        while(time() < $due)
        {
            $q = sprintf('SELECT id
                          FROM scans
                          WHERE NOT decoded
                            AND created < NOW() - INTERVAL %d SECOND
                          LIMIT 1',
                         $age);
    
            //error_log(preg_replace('/\s+/', ' ', $q));
    
            $res = $dbh->query($q);
            
            if(PEAR::isError($res)) 
                die_with_code(500, "{$res->message}\n{$q}\n");
    
            $scan = $res->fetchRow(DB_FETCHMODE_ASSOC);
            
            if(empty($scan))
                break;

            delete_scan($dbh, $scan['id']);
        }

        return true;
    }
    
    function get_scan_note(&$dbh, $scan_id, $note_number)
    {
        $q = sprintf("SELECT scan_id, note_number, note,
                             latitude, longitude, geometry,
                             UNIX_TIMESTAMP(created) AS created,
                             UNIX_TIMESTAMP(NOW()) - UNIX_TIMESTAMP(created) AS age,
                             user_id
                      FROM scan_notes
                      WHERE scan_id = %s
                        AND note_number = %s",
                     $dbh->quoteSmart($scan_id),
                     $dbh->quoteSmart($note_number));
    
        $res = $dbh->query($q);
        
        if(PEAR::isError($res)) 
            die_with_code(500, "{$res->message}\n{$q}\n");

        $row = $res->fetchRow(DB_FETCHMODE_ASSOC);
        
        return $row;
    }
    
    function get_scan_notes_count(&$dbh, $scan_id)
    {
        $q = sprintf("SELECT COUNT(note_number)
                      FROM scan_notes
                      WHERE scan_id = %s
                      AND note_number IS NOT NULL",
                      $dbh->quoteSmart($scan_id));
    
        $res = $dbh->query($q);
        
        if(PEAR::isError($res)) 
            die_with_code(500, "{$res->message}\n{$q}\n");

        $row = $res->fetchRow(DB_FETCHMODE_ASSOC);
        
        return $row;   
    }
    
    function get_scan_notes(&$dbh, $args, $page)
    {
        list($count, $offset, $perpage, $page) = get_pagination($page);
        
        $where_clauses = array('1');
        
        if(is_array($args['scans']))
        {
            $scan_ids = array_map(array(&$dbh, 'quoteSmart'), $args['scans']);
            $where_clauses[] = sprintf('(scan_id IN (%s))', join(',', $scan_ids));
        }
        
        if(isset($args['scan']))
        {
            $where_clauses[] = sprintf('(scan_id = %s)', $dbh->quoteSmart($args['scan']));
        }
        
        if(isset($args['user']))
        {
            $where_clauses[] = sprintf('(user_id = %s)', $dbh->quoteSmart($args['user']));
        }
        
        $q = sprintf('SELECT scan_id, note_number, note,
                             latitude, longitude, geometry,
                             UNIX_TIMESTAMP(created) AS created,
                             UNIX_TIMESTAMP(NOW()) - UNIX_TIMESTAMP(created) AS age,
                             user_id
                      FROM scan_notes
                      WHERE %s
                      ORDER BY created DESC
                      LIMIT %d OFFSET %d',
                     join(' AND ', $where_clauses),
                     $count, $offset);
    
        $res = $dbh->query($q);
        
        if(PEAR::isError($res)) 
            die_with_code(500, "{$res->message}\n{$q}\n");

        $rows = array();
        
        while($row = $res->fetchRow(DB_FETCHMODE_ASSOC))
            $rows[] = $row;
        
        return $rows;
    }
    
    function add_scan_note(&$dbh, $scan_id, $note_number)
    {
        $q = sprintf('INSERT INTO scan_notes
                      SET scan_id = %s, note_number = %d',
                     $dbh->quoteSmart($scan_id),
                     $dbh->quoteSmart($note_number));

        error_log(preg_replace('/\s+/', ' ', $q));

        $res = $dbh->query($q);
        
        if(PEAR::isError($res)) 
        {
            die_with_code(500, "{$res->message}\n{$q}\n");
        }
        
        return get_scan_note($dbh, $scan_id, $note_number);
    }
    
    function set_scan_note(&$dbh, $note)
    {
        $old_note = get_scan_note($dbh, $note['scan_id'], $note['note_number']);
        
        if(!$old_note)
            return false;

        $update_clauses = array();

        foreach(array('latitude', 'longitude', 'note', 'geometry', 'user_id') as $field)
            if(!is_null($note[$field]))
                if($note[$field] != $old_note[$field])
                    $update_clauses[] = sprintf('%s = %s', $field, $dbh->quoteSmart($note[$field]));

        if(empty($update_clauses)) {
            error_log("skipping note {$note['scan_id']}/{$note['note_number']} update since there's nothing to change");

        } else {
            $update_clauses = join(', ', $update_clauses);
            
            $q = sprintf('UPDATE scan_notes SET %s
                          WHERE scan_id = %s
                            AND note_number = %s',
                         $update_clauses,
                         $dbh->quoteSmart($note['scan_id']),
                         $dbh->quoteSmart($note['note_number']));
            
            error_log(preg_replace('/\s+/', ' ', $q));
    
            $res = $dbh->query($q);
            
            if(PEAR::isError($res))
                die_with_code(500, "{$res->message}\n{$q}\n");
        }

        return get_scan_note($dbh, $note['scan_id'], $note['note_number']);
    }
    
    function remove_scan_note($dbh, $scan_id, $note_number)
    {
        $q = sprintf('DELETE FROM scan_notes
              WHERE scan_id = %s AND note_number = %s',
             $dbh->quoteSmart($scan_id),
             $dbh->quoteSmart($note_number));
             
        error_log(preg_replace('/\s+/', ' ', $q));
        
        $res = $dbh->query($q);
        
        if(PEAR::isError($res)) 
        {
            die_with_code(500, "{$res->message}\n{$q}\n");
        }
    }
    
    function scan_notes_to_geojson($notes)
    {
        $geojson = array(
            'type' => 'FeatureCollection',
            'features' => array()
        );
        
        $base_href = 'http://'.get_domain_name().get_base_dir();
        
        foreach($notes as $note)
        {
            $scan = $note['scan'];
        
            $feature = array(
                'type' => 'Feature',
                'id' => "{$note['scan_id']}/{$note['note_number']}",
                'properties' => array(
                    'note' => $note['note'],
                    'number' => intval($note['note_number']),
                    'created' => date('c', $note['created']),

                    'scan_id' => $note['scan_id'],
                    'scan_href' => "{$base_href}/snapshot.php?id={$note['scan_id']}",
                    'scan_description' => $scan['description'],
                    'scan_place_woeid' => $scan['place_woeid'],
                    'scan_region_woeid' => $scan['region_woeid'],
                    'scan_country_woeid' => $scan['country_woeid'],
                    'scan_place_name' => $scan['place_name'],
                    'scan_region_name' => $scan['region_name'],
                    'scan_country_name' => $scan['country_name'],
                    'scan_created' => date('c', $scan['created'])
                ),
                'geometry' => array(
                    'type' => 'Point',
                    'coordinates' => array(floatval($note['longitude']), floatval($note['latitude']))
                )
            );
            
            $geojson['features'][] = $feature;
        }
        
        return json_encode($geojson);
    }
    
?>