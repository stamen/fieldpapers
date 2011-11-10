<?php

    function MMaps_Tiles_toBinaryString($i)
    {
        return base_convert($i, 10, 2);
    }

    function MMaps_Tiles_fromBinaryString($s)
    {
        return intval(base_convert($s, 2, 10));
    }
    
    function MMaps_Tiles_fromYahoo($x, $y, $z)
    {
        $zoom = 18 - $z;
        $row = round(pow(2, $zoom - 1) - $y - 1);
        $col = $x;
        return array($col, $row, $zoom);
    }
    
    function MMaps_Tiles_toYahoo($col, $row, $zoom)
    {
        $x = $col;
        $y = round(pow(2, $zoom - 1) - $row - 1);
        $z = 18 - $zoom;
        return array($x, $y, $z);
    }
    
    function MMaps_Tiles_fromYahooRoad($x, $y, $z)
    {
        return MMaps_Tiles_fromYahoo($x, $y, $z);
    }
    
    function MMaps_Tiles_toYahooRoad($x, $y, $z)
    {
        return MMaps_Tiles_toYahoo($x, $y, $z);
    }
    
    function MMaps_Tiles_fromYahooAerial($x, $y, $z)
    {
        return MMaps_Tiles_fromYahoo($x, $y, $z);
    }
    
    function MMaps_Tiles_toYahooAerial($x, $y, $z)
    {
        return MMaps_Tiles_toYahoo($x, $y, $z);
    }
    
    
    
    function MMaps_Tiles_fromMicrosoft($s)
    {
        $row = '';
        $col = '';
        $zoom = strlen($s);
        
        for($i = 0; $i < $zoom; $i += 1)
        {
            $rowcol = sprintf('%02s', base_convert($s{$i}, 4, 2));
            $row .= $rowcol{0};
            $col .= $rowcol{1};
        }
        
        $row = intval(base_convert($row, 2, 10));
        $col = intval(base_convert($col, 2, 10));
        
        return array($col, $row, $zoom);
    }
    
    function MMaps_Tiles_toMicrosoft($col, $row, $zoom)
    {
        $row = sprintf("%0{$zoom}s", base_convert($row, 10, 2));
        $col = sprintf("%0{$zoom}s", base_convert($col, 10, 2));
        $s = '';
        
        for($i = 0; $i < $zoom; $i += 1)
        {
            $s .= base_convert($row{$i}.$col{$i}, 2, 4);
        }
        
        return $s;
    }
    
    function MMaps_Tiles_fromMicrosoftRoad($s)
    {
        return MMaps_Tiles_fromMicrosoft($s);
    }
    
    function MMaps_Tiles_toMicrosoftRoad($x, $y, $z)
    {
        return MMaps_Tiles_toMicrosoft($x, $y, $z);
    }
    
    function MMaps_Tiles_fromMicrosoftAerial($s)
    {
        return MMaps_Tiles_fromMicrosoft($s);
    }
    
    function MMaps_Tiles_toMicrosoftAerial($x, $y, $z)
    {
        return MMaps_Tiles_toMicrosoft($x, $y, $z);
    }

?>