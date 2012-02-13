<?php

    require_once 'data.php';
    
    function get_scan_note(&$dbh, $scan_id, $note_number)
    {
        $q = sprintf("SELECT scan_id, note_number, note,
                             latitude, longitude, geometry
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
    
    function get_scan_notes(&$dbh, $scan_id, $page)
    {
        list($count, $offset, $perpage, $page) = get_pagination($page);
        
        $q = sprintf('SELECT scan_id, note_number, note,
                             latitude, longitude, geometry
                      FROM scan_notes
                      WHERE %s
                      ORDER BY created DESC
                      LIMIT %d OFFSET %d',
                     ($scan_id ? 'scan_id = '.$dbh->quoteSmart($scan_id) : '1'),
                     $count,
                     $offset);
    
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
    
?>