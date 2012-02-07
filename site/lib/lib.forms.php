<?php

    require_once 'data.php';

    function add_form(&$dbh, $user_id)
    {
        while(true)
        {
            $form_id = generate_id();
            
            $q = sprintf('INSERT INTO forms
                          SET id = %s, user_id = %s',
                         $dbh->quoteSmart($form_id),
                         $dbh->quoteSmart($user_id));

            error_log(preg_replace('/\s+/', ' ', $q));
    
            $res = $dbh->query($q);
            
            if(PEAR::isError($res)) 
            {
                if($res->getCode() == DB_ERROR_ALREADY_EXISTS)
                    continue;
    
                die_with_code(500, "{$res->message}\n{$q}\n");
            }
            
            return get_form($dbh, $form_id);
        }
    }
    
    function add_form_field(&$dbh, $form_id, $name)
    {
        $q = sprintf('INSERT INTO form_fields
                      SET form_id = %s, `name` = %s',
                     $dbh->quoteSmart($form_id),
                     $dbh->quoteSmart($name));

        error_log(preg_replace('/\s+/', ' ', $q));

        $res = $dbh->query($q);
        
        if(PEAR::isError($res)) 
        {
            die_with_code(500, "{$res->message}\n{$q}\n");
        }
        
        return get_form_field($dbh, $form_id, $name);
    }
    
    function get_forms(&$dbh, $page)
    {
        list($count, $offset, $perpage, $page) = get_pagination($page);
        
        $q = sprintf("SELECT id, title, http_method, action_url,
                             UNIX_TIMESTAMP(created) AS created,
                             UNIX_TIMESTAMP(parsed) AS parsed,
                             UNIX_TIMESTAMP(NOW()) - UNIX_TIMESTAMP(created) AS age,
                             user_id
                      FROM forms
                      WHERE parsed
                      ORDER BY created DESC
                      LIMIT %d OFFSET %d",
                     $count, $offset);
    
        $res = $dbh->query($q);
        
        if(PEAR::isError($res)) 
            die_with_code(500, "{$res->message}\n{$q}\n");

        $rows = array();
        
        while($row = $res->fetchRow(DB_FETCHMODE_ASSOC))
            $rows[] = $row;
        
        return $rows;
    }
    
    function get_form(&$dbh, $form_id)
    {
        $q = sprintf("SELECT id, title, http_method, action_url,
                             UNIX_TIMESTAMP(created) AS created,
                             UNIX_TIMESTAMP(parsed) AS parsed,
                             UNIX_TIMESTAMP(NOW()) - UNIX_TIMESTAMP(created) AS age,
                             user_id
                      FROM forms
                      WHERE id = %s",
                     $dbh->quoteSmart($form_id));
    
        $res = $dbh->query($q);
        
        if(PEAR::isError($res)) 
            die_with_code(500, "{$res->message}\n{$q}\n");

        $row = $res->fetchRow(DB_FETCHMODE_ASSOC);
        
        return $row;
    }
    
    function get_form_fields(&$dbh, $form_id)
    {
        $q = sprintf("SELECT form_id, `name`, label, `type`
                      FROM form_fields
                      WHERE form_id = %s",
                     $dbh->quoteSmart($form_id));
    
        $res = $dbh->query($q);
        
        if(PEAR::isError($res)) 
            die_with_code(500, "{$res->message}\n{$q}\n");

        $rows = array();
        
        while($row = $res->fetchRow(DB_FETCHMODE_ASSOC))
            $rows[] = $row;
        
        return $rows;
    }
    
    function get_form_field(&$dbh, $form_id, $name)
    {
        $q = sprintf("SELECT form_id, `name`, label, `type`
                      FROM form_fields
                      WHERE form_id = %s
                        AND `name` = %s",
                     $dbh->quoteSmart($form_id),
                     $dbh->quoteSmart($name));
    
        $res = $dbh->query($q);
        
        if(PEAR::isError($res)) 
            die_with_code(500, "{$res->message}\n{$q}\n");

        $row = $res->fetchRow(DB_FETCHMODE_ASSOC);
        
        return $row;
    }
    
    function set_form(&$dbh, $form)
    {
        $old_form = get_form($dbh, $form['id']);
        
        if(!$old_form)
            return false;

        $update_clauses = array();

        foreach(array('form_url', 'http_method', 'action_url', 'title', 'user_id') as $field)
            if(!is_null($form[$field]))
                if($form[$field] != $old_form[$field])
                    $update_clauses[] = sprintf('%s = %s', $field, $dbh->quoteSmart($form[$field]));

        if(empty($update_clauses)) {
            error_log("skipping form {$form['id']} update since there's nothing to change");

        } else {
            $update_clauses = join(', ', $update_clauses);
            
            $q = "UPDATE forms
                  SET {$update_clauses}
                  WHERE id = ".$dbh->quoteSmart($form['id']);
    
            error_log(preg_replace('/\s+/', ' ', $q));
    
            $res = $dbh->query($q);
            
            if(PEAR::isError($res))
                die_with_code(500, "{$res->message}\n{$q}\n");
        }

        return get_form($dbh, $form['id']);
    }
    
    function set_form_field(&$dbh, $field)
    {
        $old_field = get_form_field($dbh, $field['form_id'], $field['name']);
        
        if(!$old_field)
            return false;

        $update_clauses = array();

        foreach(array('label', 'type') as $column)
            if(!is_null($field[$column]))
                if($field[$column] != $oldcolumn[$column])
                    $update_clauses[] = sprintf('`%s` = %s', $column, $dbh->quoteSmart($field[$column]));

        if(empty($update_clauses)) {
            error_log("skipping field {$field['form_id']}/{$field['name']} update since there's nothing to change");

        } else {
            $update_clauses = join(', ', $update_clauses);
            
            $q = sprintf('UPDATE form_fields SET %s
                          WHERE form_id = %s
                            AND `name` = %s',
                         $update_clauses,
                         $dbh->quoteSmart($field['form_id']),
                         $dbh->quoteSmart($field['name']));
            
            error_log(preg_replace('/\s+/', ' ', $q));
    
            $res = $dbh->query($q);
            
            if(PEAR::isError($res))
                die_with_code(500, "{$res->message}\n{$q}\n");
        }

        return get_form_field($dbh, $field['form_id'], $field['name']);
    }
    
    function finish_form(&$dbh, $form_id)
    {
        $q = sprintf('UPDATE forms SET parsed = NOW() WHERE id = %s',
                     $dbh->quoteSmart($form_id));

        error_log(preg_replace('/\s+/', ' ', $q));

        $res = $dbh->query($q);
        
        if(PEAR::isError($res))
            die_with_code(500, "{$res->message}\n{$q}\n");
    }
    
    function fail_form(&$dbh, $form_id, $failure=1)
    {
        $q = sprintf('UPDATE forms SET failed = %s WHERE id = %s',
                     $dbh->quoteSmart($failure),
                     $dbh->quoteSmart($form_id));

        error_log(preg_replace('/\s+/', ' ', $q));

        $res = $dbh->query($q);
        
        if(PEAR::isError($res))
            die_with_code(500, "{$res->message}\n{$q}\n");
    }
    
?>