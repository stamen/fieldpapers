<?php

    function add_user(&$dbh)
    {
        while(true)
        {
            $user_id = generate_id();
            
            $q = sprintf('INSERT INTO users
                          SET id = %s',
                         $dbh->quoteSmart($user_id));

            error_log(preg_replace('/\s+/', ' ', $q));
    
            $res = $dbh->query($q);
            
            if(PEAR::isError($res)) 
            {
                if($res->getCode() == DB_ERROR_ALREADY_EXISTS)
                    continue;
    
                die_with_code(500, "{$res->message}\n{$q}\n");
            }
            
            return get_user($dbh, $user_id);
        }
    }
    
    function get_user(&$dbh, $user_id)
    {
        $q = sprintf('SELECT id, name,
                             UNIX_TIMESTAMP(created) AS created,
                             UNIX_TIMESTAMP(NOW()) - UNIX_TIMESTAMP(created) AS age
                      FROM users
                      WHERE id = %s',
                     $dbh->quoteSmart($user_id));
    
        $res = $dbh->query($q);
        
        if(PEAR::isError($res)) 
            die_with_code(500, "{$res->message}\n{$q}\n");

        return $res->fetchRow(DB_FETCHMODE_ASSOC);
    }
    
?>
