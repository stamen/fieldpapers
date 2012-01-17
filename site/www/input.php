<?php
    session_start();

    //POST variables
    
    $username = $_POST['username'];
    $password = $_POST['password'];
    
    //Check if they've put both in
    
    if ($username && $password) {
        echo "Thanks " . $username . "!";
    } else {
        die("Please enter a username and a password");
    }
    
    $_SESSION['username'] = $username;
?>