<?php

    require_once '../lib/lib.everything.php';
    require_once '../lib/lib.compose.php';
    
    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);
    
    $context = default_context(True);
    
    /**** ... ****/
    
    $is_json = false;

    foreach(getallheaders() as $header => $value)
    {
        if(strtolower($header) == 'content-type')
        {
            $is_json = preg_match('#\b(text|application)/json\b#i', $value);
            $json_content = file_get_contents('php://input');
        }
    }
    
    if(!$is_json && isset($_FILES['geojson_file']) && is_uploaded_file($_FILES['geojson_file']['tmp_name']))
    {
        $is_json = true;
        $json_content = file_get_contents($_FILES['geojson_file']['tmp_name']);
    }
    
    if(!$is_json && isset($_POST['geojson_data']))
    {
        $is_json = true;
        $json_content = $_POST['geojson_data'];
    }
    
    $clone_job = false;
    $clone_id = 0;
    if(isset($_POST['clone_id'])){
        $clone_job = true;
        $clone_id = $_POST['clone_id'];
    }

    $refresh_job = false;
    $refresh_id = 0;
    if(isset($_POST['refresh_id'])){
        $refresh_job = true;
        $refresh_id = $_POST['refresh_id'];
    }
    
    if($_SERVER['REQUEST_METHOD'] == 'POST')
    {      
        $context->db->query('START TRANSACTION');
        
        if($is_json) {
            $print = compose_from_geojson($context->db, $json_content);

        }else{
    
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
            if($clone_job && $clone_id){
                $print = compose_clone($context->db, $atlas_postvars, $context->user['id'], $clone_id, false);
            }elseif($refresh_job && $refresh_id){
                $print = compose_clone($context->db, $atlas_postvars, $context->user['id'], $refresh_id, true);
            }else{
                $print = compose_from_postvars($context->db, $atlas_postvars, $context->user['id']);
            }
        }
        
        $context->db->query('COMMIT');
        
        if(is_null($print))
            die_with_code(400, "Missing... Something.");
        
        $print_url = 'http://'.get_domain_name().get_base_dir().'/atlas.php?id='.urlencode($print['id']);
        header("Location: {$print_url}");
    }
    
?>
