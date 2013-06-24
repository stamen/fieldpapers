<?php

    require_once '../lib/lib.everything.php';
    
    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);
    
    $context = default_context(True);
    
    /**** ... ****/
    
    $error = '';
    if(isset($_POST['form_url']))
    {
        if(empty($_POST['form_url']))
        {
            $error = "Empty or missing form_url.";
        }
        
        if(empty($error)){   
            $added_form = add_form($context->db, $context->user['id']);
            $added_form['form_url'] = $_POST['form_url'];
    
            if(!empty($_POST['form_title']))
            {
                $added_form['title'] = $_POST['form_title'];
            }

            set_form($context->db, $added_form);
            
            $message = array('action' => 'import form',
                             'url' => $_POST['form_url'],
                             'form_id' => $added_form['id']);
                
            // queue the task
            queue_task("tasks.parseForm", array("http://" . SERVER_NAME, API_PASSWORD), $message);
            
            $form_url = 'http://'.get_domain_name().get_base_dir().'/form.php?id='.urlencode($added_form['id']);
            header("Location: {$form_url}");
            
            exit();
        }
    }
    

    if($context->type == 'text/html') {
        if(!empty($error))$context->sm->assign('error', $error);
        
        header("Content-Type: text/html; charset=UTF-8");
        print $context->sm->fetch("add-form.html.tpl");
    
    } else {
        header('HTTP/1.1 400');
        $error = "Unknown type.";
        $context->sm->assign('error', $error);
        header("Content-Type: text/html; charset=UTF-8");                                                                                                      
        print $context->sm->fetch("add-form.html.tpl");  
    }

?>
