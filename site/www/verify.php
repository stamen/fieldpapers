<?php

    require_once '../lib/lib.everything.php';
    
    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);
    
    $context = default_context();
    
    /**** ... ****/
    
    if ($_GET['email'] && $_GET['hash']) 
    {
        
        $q = sprintf("SELECT email, hash, activated FROM users WHERE email=%s AND hash=%s",
                     $context->db->quoteSmart($_GET['email']),
                     $context->db->quoteSmart($_GET['hash']));

        $res_search = $context->db->query($q);
        $match = $res_search->fetchRow(DB_FETCHMODE_ASSOC);
        
        if ($match)
        {  
            $q = sprintf("UPDATE users SET activated=NOW() WHERE email=%s AND hash=%s AND NOT activated",
                        $context->db->quoteSmart($_GET['email']),
                        $context->db->quoteSmart($_GET['hash']));
    
            $res = $context->db->query($q);

            echo 'Congratulations! You are now activated.';
        } else {
            die('The url may be bad or your account may already be activated.');
        }
    } else {
        die('Your link is bad. Check the link sent in your email.');
    }
?>