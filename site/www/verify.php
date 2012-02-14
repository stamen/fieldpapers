<?php

    require_once '../lib/lib.everything.php';
    
    $language = $_SERVER['HTTP_ACCEPT_LANGUAGE'];
    enforce_master_on_off_switch($language);
    
    $dbh =& get_db_connection();
    
    if ($_GET['email'] && $_GET['hash']) 
    {
        
        $q = sprintf("SELECT email, hash, activated FROM users WHERE email=%s AND hash=%s",
                     $dbh->quoteSmart($_GET['email']),
                     $dbh->quoteSmart($_GET['hash']));

        $res_search = $dbh->query($q);
        $match = $res_search->fetchRow(DB_FETCHMODE_ASSOC);
        
        if ($match)
        {  
            $q = sprintf("UPDATE users SET activated=NOW() WHERE email=%s AND hash=%s AND NOT activated",
                        $dbh->quoteSmart($_GET['email']),
                        $dbh->quoteSmart($_GET['hash']));
    
            $res = $dbh->query($q);

            echo 'Congratulations! You are now activated.';
        } else {
            die('The url may be bad or your account may already be activated.');
        }
    } else {
        die('Your link is bad. Check the link sent in your email.');
    }
?>