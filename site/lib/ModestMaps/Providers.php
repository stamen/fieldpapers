<?php

    require_once 'Geo.php';

    class MMaps_Templated_Spherical_Mercator_Provider
    {
        var $projection;
        var $templates;
        var $tile_width;
        var $tile_height;
    
        function MMaps_Templated_Spherical_Mercator_Provider($template)
        {
            $t = new MMaps_Transformation(1.068070779e7, 0, 3.355443185e7,
                                          0, -1.068070890e7, 3.355443057e7);

            $this->projection = new MMaps_Mercator_Projection(26, $t);
            
            $this->templates = array();
            
            while($template)
            {
                if(preg_match('#^(http://\S+?)(,http://\S+)?$#i', $template, $matches))
                {
                    $this->templates[] = $matches[1];
                    
                    $template = $matches[2]
                        ? substr($template, strlen($matches[1]) + 1)
                        : '';
                }
            }
            
            $this->tile_width = 256;
            $this->tile_height = 256;
        }
        
        function locationCoordinate($location)
        {
            return $this->projection->locationCoordinate($location);
        }

        function coordinateLocation($coordinate)
        {
            return $this->projection->coordinateLocation($coordinate);
        }
        
        function getTileURLs($coord)
        {
            $urls = array();
            
            foreach($this->templates as $template)
                $urls[] = str_replace('{X}', intval($coord->column), str_replace('{Y}', intval($coord->row), str_replace('{Z}', intval($coord->zoom), $template)));
                
            return $urls;
        }
    }
    
    class MMaps_OpenStreetMap_Provider extends MMaps_Templated_Spherical_Mercator_Provider
    {
        function MMaps_OpenStreetMap_Provider()
        {
            MMaps_Templated_Spherical_Mercator_Provider::MMaps_Templated_Spherical_Mercator_Provider('http://tile.openstreetmap.org/{Z}/{X}/{Y}.png');
        }
    }
    
?>
