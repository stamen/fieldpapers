<?php

    require_once 'Geo.php';
    require_once 'Core.php';
    require_once 'Providers.php';

    class Modest_Map
    {
        var $provider;
        var $dimensions;
        var $coordinate;
        var $offset;
        
        function Modest_Map($provider, $dimensions, $coordinate, $offset)
        {
            $this->provider = $provider;
            $this->dimensions = $dimensions;
            $this->coordinate = $coordinate;
            $this->offset = $offset;
        }
        
        function locationPoint($location)
        {
            $point = $this->offset->copy();
            $coord = $this->provider->locationCoordinate($location)->zoomTo($this->coordinate->zoom);
            
            // distance from the known coordinate offset
            $point->x += $this->provider->tile_width * ($coord->column - $this->coordinate->column);
            $point->y += $this->provider->tile_height * ($coord->row - $this->coordinate->row);
            
            // because of the center/corner business
            $point->x += $this->dimensions->x / 2;
            $point->y += $this->dimensions->y / 2;
            
            return $point;
        }
        
        function pointLocation($point)
        {
            $hizoomCoord = $this->coordinate->zoomTo(MMaps_Coordinate_Max_Zoom);
            
            // because of the center/corner business
            $point = new MMaps_Point($point->x - $this->dimensions->x/2,
                                     $point->y - $this->dimensions->y/2);

            // distance in tile widths from reference tile to point
            $xTiles = ($point->x - $this->offset->x) / $this->provider->tile_width;
            $yTiles = ($point->y - $this->offset->y) / $this->provider->tile_height;
            
            // distance in rows & columns at maximum zoom
            $xDistance = $xTiles * pow(2, (MMaps_Coordinate_Max_Zoom - $this->coordinate->zoom));
            $yDistance = $yTiles * pow(2, (MMaps_Coordinate_Max_Zoom - $this->coordinate->zoom));
            
            // new point coordinate reflecting that distance
            $coord = new MMaps_Coordinate(round($hizoomCoord->row + $yDistance),
                                          round($hizoomCoord->column + $xDistance),
                                          $hizoomCoord->zoom);

            $coord = $coord->zoomTo($this->coordinate->zoom);
            $location = $this->provider->coordinateLocation($coord);
            
            return $location;
        }
        
        function draw()
        {
            $coord = $this->coordinate->copy();
            $corner = new MMaps_Point(floor($this->offset->x + $this->dimensions->x/2), floor($this->offset->y + $this->dimensions->y/2));
            
            while($corner->x > 0)
            {
                $corner->x -= $this->provider->tile_width;
                $coord = $coord->left();
            }
            
            while($corner->y > 0)
            {
                $corner->y -= $this->provider->tile_height;
                $coord = $coord->up();
            }
            
            $tiles = array();
            $rowCoord = $coord->copy();
            
            for($y = $corner->y; $y < $this->dimensions->y; $y += $this->provider->tile_height)
            {
                $tileCoord = $rowCoord->copy();
                
                for($x = $corner->x; $x < $this->dimensions->x; $x += $this->provider->tile_width)
                {
                    $tiles[] = array($this->provider->getTileURLs($tileCoord), new MMaps_Point($x, $y));
                    $tileCoord = $tileCoord->right();
                }
                
                $rowCoord = $rowCoord->down();
            }
            
            return MMaps_renderTiles($this->provider, $tiles, $this->dimensions->x, $this->dimensions->y);
        }
    }
    
    function MMaps_renderTiles($provider, $tiles, $width, $height)
    {
        $img = imagecreatetruecolor($width, $height);
        
        foreach($tiles as $tile)
        {
            list($urls, $position) = $tile;
            
            foreach($urls as $url)
            {
                $tile = @imagecreatefromstring(@file_get_contents($url));
                
                error_log("MMaps_renderTiles: {$url}");

                if($tile !== false)
                    @imagecopy($img, $tile, $position->x, $position->y, 0, 0, imagesx($tile), imagesy($tile));
            }
        }
        
        return $img;
    }

    function MMaps_calculateMapCenter($provider, $centerCoord)
    {
        // initial tile coordinate
        $initTileCoord = $centerCoord->container();
        
        // initial tile position, assuming centered tile well in grid
        $initX = ($initTileCoord->column - $centerCoord->column) * $provider->tile_width;
        $initY = ($initTileCoord->row - $centerCoord->row) * $provider->tile_height;
        $initPoint = new MMaps_Point(round($initX), round($initY));
        
        return array($initTileCoord, $initPoint);
    }
    
    function MMaps_calculateMapExtent($provider, $width, $height, $locations)
    {
        list($min_row, $min_column, $min_zoom) = array(INF, INF, INF);
        list($max_row, $max_column, $max_zoom) = array(-INF, -INF, -INF);
        
        foreach($locations as $location)
        {
            $coordinate = $provider->locationCoordinate($location);
            
            $min_row = min($min_row, $coordinate->row);
            $min_column = min($min_column, $coordinate->column);
            $min_zoom = min($min_zoom, $coordinate->zoom);
            
            $max_row = max($max_row, $coordinate->row);
            $max_column = max($max_column, $coordinate->column);
            $max_zoom = max($min_zoom, $coordinate->zoom);
        }
        
        $TL = new MMaps_Coordinate($min_row, $min_column, $min_zoom);
        $BR = new MMaps_Coordinate($max_row, $max_column, $max_zoom);
                    
        // multiplication factor between horizontal span and map width
        $hFactor = ($BR->column - $TL->column) / ($width / $provider->tile_width);

        // multiplication factor expressed as base-2 logarithm, for zoom difference
        $hZoomDiff = log($hFactor) / log(2);
        
        // possible horizontal zoom to fit geographical extent in map width
        $hPossibleZoom = $TL->zoom - ceil($hZoomDiff);
        
        // multiplication factor between vertical span and map height
        $vFactor = ($BR->row - $TL->row) / ($height / $provider->tile_height);
        
        // multiplication factor expressed as base-2 logarithm, for zoom difference
        $vZoomDiff = log($vFactor) / log(2);
        
        // possible vertical zoom to fit geographical extent in map height
        $vPossibleZoom = $TL->zoom - ceil($vZoomDiff);
        
        // initial zoom to fit extent vertically and horizontally
        $initZoom = min($hPossibleZoom, $vPossibleZoom);

        # coordinate of extent center
        $centerRow = ($TL->row + $BR->row) / 2;
        $centerColumn = ($TL->column + $BR->column) / 2;
        $centerZoom = ($TL->zoom + $BR->zoom) / 2;
        $centerCoord = new MMaps_Coordinate($centerRow, $centerColumn, $centerZoom);
        $centerCoord = $centerCoord->zoomTo($initZoom);
        
        return MMaps_calculateMapCenter($provider, $centerCoord);
    }

    function MMaps_mapByCenterZoom($provider, $center, $zoom, $dimensions)
    {
        $centerCoord = $provider->locationCoordinate($center)->zoomTo($zoom);
        list($mapCoord, $mapOffset) = MMaps_calculateMapCenter($provider, $centerCoord);
        
        return new Modest_Map($provider, $dimensions, $mapCoord, $mapOffset);
    }
    
    function MMaps_mapByExtent($provider, $locationA, $locationB, $dimensions)
    {
        list($mapCoord, $mapOffset) = MMaps_calculateMapExtent($provider, $dimensions->x, $dimensions->y, array($locationA, $locationB));
        
        return new Modest_Map($provider, $dimensions, $mapCoord, $mapOffset);
    }

    function MMaps_mapByExtentZoom($provider, $locationA, $locationB, $zoom)
    {
        // a coordinate per corner
        $coordA = $provider->locationCoordinate($locationA)->zoomTo($zoom);
        $coordB = $provider->locationCoordinate($locationB)->zoomTo($zoom);

        // precise width and height in pixels
        $width = abs($coordA->column - $coordB->column) * $provider->tile_width;
        $height = abs($coordA->row - $coordB->row) * $provider->tile_height;
    
        // nearest pixel actually
        $dimensions = new MMaps_Point(floor($width), floor($height));
    
        // projected center of the map
        $centerCoord = new MMaps_Coordinate(($coordA->row + $coordB->row) / 2,
                                            ($coordA->column + $coordB->column) / 2,
                                            $zoom);
    
        list($mapCoord, $mapOffset) = MMaps_calculateMapCenter($provider, $centerCoord);

        return new Modest_Map($provider, $dimensions, $mapCoord, $mapOffset);
    }
    
?>