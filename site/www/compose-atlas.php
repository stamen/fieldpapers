<?php

    require_once '../lib/lib.everything.php';
    require_once '../lib/lib.compose.php';
    
    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);
    
    $context = default_context();
    
    /**** ... ****/
    
    $is_json = false;

    foreach(getallheaders() as $header => $value)
    {
        if(strtolower($header) == 'content-type')
        {
            $is_json = preg_match('#\b(text|application)/json\b#i', $value);
        }
    }
    
    if($_SERVER['REQUEST_METHOD'] == 'POST')
    {       
        $context->db->query('START TRANSACTION');
        
        if($is_json) {
            $json = json_decode(file_get_contents('php://input'), true);
            $print = compose_from_geojson($context->db, file_get_contents('php://input'));

        } else {
            $atlas_postvars = $_POST;

            if(!empty($_POST['form_url']))
            {
                $added_form = add_form($context->db, $context->user['id']);
                $added_form['form_url'] = $_POST['form_url'];
                
                if(!empty($_POST['form_title']))
                {
                    $added_form['title'] = $_POST['form_title'];
                }
        
                set_form($context->db, $added_form);
                
                //
                // A new form was requested.
                // postvars will now have form_id in addition to form_url.
                //
                
                $atlas_postvars['form_id'] = $added_form['id'];
            }
            
            $print = compose_from_postvars($context->db, $atlas_postvars, $context->user['id']);
        }
        
        $context->db->query('COMMIT');
        
        $print_url = 'http://'.get_domain_name().get_base_dir().'/print.php?id='.urlencode($print['id']);
        header("Location: {$print_url}");
    }
    
?>