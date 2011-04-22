<?php

    require_once 'FPDF/fpdf.php';
    
    class Raw_PDF extends FPDF
    {
        function raw($command)
        {
            $this->_out($command);
        }
        
        function raw_jpeg($path)
        {
            $this->_add_raw_image($path, $this->_parsejpg($path));
        }
        
        function raw_png($path)
        {
            $this->_add_raw_image($path, $this->_parsepng($path));
        }
        
        function _add_raw_image($path, $info)
        {
            $info['i'] = count($this->images) + 1;
            $this->images[$path] = $info;

            // PDF's Do operator places the image into a [0,1] unit square
            list($i, $w, $h) = array($info['i'], $info['w'], $info['h']);
            $this->_out(sprintf('q %d 0 0 %d 0 %d cm /I%d Do Q', $w, -$h, $h, $i));
        }
    }
    
    $json = file_get_contents('php://stdin');
    $calls = json_decode($json, true);
    
    $pdf = new Raw_PDF('L', 'pt', 'letter');
    
    foreach($calls as $call)
    {
        list($method, $args) = $call;
        echo "$method: ".json_encode($args)."\n";
        call_user_func_array(array(&$pdf, $method), $args);
    }

    $pdf->output('out.pdf');
    
?>
