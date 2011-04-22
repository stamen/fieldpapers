<?php

    require_once 'FPDF/fpdf.php';
    
    class Raw_PDF extends FPDF
    {
        function raw($command)
        {
            // "Tj" is for showing text, which needs to be latin-1 for display.
            if(preg_match('/\bTj\b/', $command))
                $command = mb_convert_encoding($command, 'ISO-8859-1', 'UTF-8');

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
    $info = json_decode($json, true);
    
    // always "P" because info[size] is ordered.
    $pdf = new Raw_PDF('P', 'pt', $info['size']);
    
    foreach($info['commands'] as $cmd)
    {
        list($method, $args) = $cmd;
        //echo "$method: ".json_encode($args)."\n";
        call_user_func_array(array(&$pdf, $method), $args);
    }

    $pdf->output($info['filename']);
    
?>
