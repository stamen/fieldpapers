<?php

    require_once 'data.php';
    
    function get_scan_notes(&$dbh, $scan_id, $page)
    {
        list($count, $offset, $perpage, $page) = get_pagination($page);
        
        $q = sprintf('SELECT scan_id, number, note,
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
    
?>