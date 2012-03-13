<?php

   /*
   
    Require *almost* everything.
    Skip libraries used so rarely it's not worth including them.
   
    */

    require_once 'init.php';
    require_once 'data.php';
    require_once 'output.php';

    require_once 'lib.auth.php';
    require_once 'lib.forms.php';
    require_once 'lib.mbtiles.php';
    require_once 'lib.prints.php';
    require_once 'lib.scans.php';
    
    function &default_context()
    {
        $db =& get_db_connection();
        $sm =& get_smarty_instance();
        
        $user = null;
        $type = get_preferred_type($_GET['type'] ? $_GET['type'] : $_SERVER['HTTP_ACCEPT']);
        
        if($type == 'text/html')
        {
            // get the session user if there is one

            session_set_cookie_params(86400 * 31, get_base_dir());
            session_start();
            
            $user = cookied_user(&$db);
            
            if(!$user)
            {
                $user = add_user(&$db);
                login_user_by_id(&$db, $user['id']);
            }
        }

        $ctx = new Context($db, $sm, $user, $type);

        return $ctx;
    }

?>