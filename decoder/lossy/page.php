<?php

    require_once 'FPDF/fpdf.php';
    
    class Raw_PDF extends FPDF
    {
        function raw($command)
        {
            $this->_out($command);
        }
    }
    
    $json = file_get_contents('php://stdin');
    $calls = json_decode($json, true);
    
    $pdf = new Raw_PDF('L', 'pt', 'letter');
    $pdf->addpage();
    
    foreach($calls as $call)
    {
        list($method, $args) = $call;
        echo "$method: ".json_encode($args)."\n";
        call_user_func_array(array(&$pdf, $method), $args);
    }

    $pdf->output('out.pdf');
    
?>
