<?php

    require_once '../lib/lib.everything.php';
    
    enforce_master_on_off_switch($_SERVER['HTTP_ACCEPT_LANGUAGE']);
    
    $context = default_context(True);

    /**** ... ****/
    
    $scan_args = array(
        'date' => preg_match('#^\d{4}-\d\d-\d\d$#', $_GET['date']) ? $_GET['date'] : null,
        'month' => preg_match('#^\d{4}-\d\d$#', $_GET['month']) ? $_GET['month'] : null,
        'place' => is_numeric($_GET['place']) ? $_GET['place'] : null,
        'user' => preg_match('/^\w+$/', $_GET['user']) ? $_GET['user'] : null
        );
    
     
    // set intial pagination request params
    // TODO: globalize prints_per_page    
    $prints_per_page = 50;
    $page_num = 1;
    if(isset($_GET['page'])){
        $page_num = intval($_GET['page']);
    }    
    
    $pagination_args = array(
        'perpage' => $prints_per_page,
        'page'  => $page_num
    );

 
    $title = get_args_title($context->db, $scan_args);
    list($scans, $pagination_results, $where_clauses) = get_scans($context->db, $scan_args, $pagination_args);

    // get total count of prints
    // passing in $print_args array to keep count in sync 
    $scans_total = get_scans_count($context->db, $where_clauses);

    // update pagination results
    $pagination_results = get_scans_pagination_display_obj($pagination_results, $scans_total, $scan_args);
 
    $users = array(); 
    foreach($scans as $i => $scan)
    {   
        $user_id = $print['user_id'];
        
        if($users[$user_id] == null && $user_id != null)
            $users[$user_id] = get_user($context->db, $user_id);
        
        $scans[$i]['user'] = $users[$user_id];
        
        if($scan['print_id'])
            $scans[$i]['print'] = get_print($context->db, $scan['print_id']);
    }
    
    $context->sm->assign('pagination',$pagination_results);  
    $context->sm->assign('title', $title);
    $context->sm->assign('scans', $scans);
    $context->sm->assign('query_without_page', http_build_query($scan_args));

    if($context->type == 'text/html') {
        header("Content-Type: text/html; charset=UTF-8");
        print $context->sm->fetch("snapshots.html.tpl");
    
    } else {
        header('HTTP/1.1 400');
        die("Unknown type.\n");
    }

?>
