<?php

    define('MMaps_Coordinate_Max_Zoom', 25);

    class MMaps_Point
    {
        var $x;
        var $y;
        
        function MMaps_Point($x, $y)
        {
            $this->x = $x;
            $this->y = $y;
        }
        
        function toString()
        {
            return sprintf('(%.3f, %.3f)', $this->x, $this->y);
        }
        
        function copy()
        {
            return new MMaps_Point($this->x, $this->y);
        }
    }
    
    class MMaps_Coordinate
    {
        var $row;
        var $column;
        var $zoom;
        
        function MMaps_Coordinate($row, $column, $zoom)
        {
            $this->row = $row;
            $this->column = $column;
            $this->zoom = $zoom;
        }
        
        function toString()
        {
            return sprintf('(%.3f, %.3f @%.3f)', $this->row, $this->column, $this->zoom);
        }
        
        function equalTo($other)
        {
            return $this->row == $other->row && $this->column == $other->column && $this->zoom == $other->zoom;
        }
        
        function copy()
        {
            return new MMaps_Coordinate($this->row, $this->column, $this->zoom);
        }
        
        function container()
        {
            return new MMaps_Coordinate(floor($this->row), floor($this->column), $this->zoom);
        }
        
        function zoomTo($destination)
        {
            return new MMaps_Coordinate($this->row * pow(2, $destination - $this->zoom),
                                        $this->column * pow(2, $destination - $this->zoom),
                                        $destination);
        }
        
        function zoomBy($distance)
        {
            return new MMaps_Coordinate($this->row * pow(2, $distance),
                                        $this->column * pow(2, $distance),
                                        $this->zoom + $distance);
        }
        
        function up($distance=1)
        {
            return new MMaps_Coordinate($this->row - $distance, $this->column, $this->zoom);
        }
        
        function right($distance=1)
        {
            return new MMaps_Coordinate($this->row, $this->column + $distance, $this->zoom);
        }
        
        function down($distance=1)
        {
            return new MMaps_Coordinate($this->row + $distance, $this->column, $this->zoom);
        }
        
        function left($distance=1)
        {
            return new MMaps_Coordinate($this->row, $this->column - $distance, $this->zoom);
        }
    }

?>