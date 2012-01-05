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
    
    function set_user(&$dbh, $user)
    {
        $old_user = get_user($dbh, $user['id']);
        
        if(!$old_user)
            return false;

        $update_clauses = array();

        if(!is_null($user['name']) && $user['name'] != $old_user['name'])
            $update_clauses[] = sprintf('name = %s', $dbh->quoteSmart($user['name']));
        
        if(!is_null($user['email']) && $user['email'] != $old_user['email'])
            $update_clauses[] = sprintf('email = %s', $dbh->quoteSmart($user['email']));
        
        if(!is_null($user['password']))
            $update_clauses[] = sprintf('password = SHA1(%s)', $dbh->quoteSmart($user['password']));
        
        if(empty($update_clauses)) {
            error_log("skipping user {$user['id']} update since there's nothing to change");

        } else {
            $update_clauses = join(', ', $update_clauses);
            
            $q = "UPDATE users
                  SET {$update_clauses}
                  WHERE id = ".$dbh->quoteSmart($user['id']);
    
            error_log(preg_replace('/\s+/', ' ', $q));
    
            $res = $dbh->query($q);
            
            if(PEAR::isError($res))
                die_with_code(500, "{$res->message}\n{$q}\n");
        }

        return get_user($dbh, $user['id']);
    }
    
    function delete_user(&$dbh, $user_id)
    {
        $q = sprintf('DELETE FROM users
                      WHERE id = %s',
                     $dbh->quoteSmart($user_id));

        error_log(preg_replace('/\s+/', ' ', $q));

        $res = $dbh->query($q);
        
        if(PEAR::isError($res)) 
            die_with_code(500, "{$res->message}\n{$q}\n");

        return true;
    }
    
   /**
    * Return true if a given user ID and password match the database.
    */
    function check_user_password(&$dbh, $user_id, $password)
    {
        $q = sprintf('SELECT %s = SHA1(password)
                      FROM users
                      WHERE id = %s
                      LIMIT 1',
                     $dbh->quoteSmart($password),
                     $dbh->quoteSmart($user_id));
    
        $res = $dbh->query($q);
        
        if(PEAR::isError($res)) 
            die_with_code(500, "{$res->message}\n{$q}\n");

        $match = $res->fetchRow();
        
        return $match[0] ? true : false;
    }
    
?>
