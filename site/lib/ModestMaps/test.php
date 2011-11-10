<?php

    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.dirname(__FILE__).'/../lib'.PATH_SEPARATOR.'/usr/share/pear');
    require_once 'Geo.php';
    require_once 'Core.php';
    require_once 'Tiles.php';
    require_once 'Providers.php';
    require_once 'ModestMaps.php';
    require_once 'PHPUnit.php';
    
    class Tiles_TestCase extends PHPUnit_TestCase
    {
        function setUp()
        {
        }
        
        function test_binary_strings()
        {
            $this->assertEquals('1', MMaps_Tiles_toBinaryString(1), 'To binary string');
            $this->assertEquals('10', MMaps_Tiles_toBinaryString(2), 'To binary string');
            $this->assertEquals('11', MMaps_Tiles_toBinaryString(3), 'To binary string');
            $this->assertEquals('100', MMaps_Tiles_toBinaryString(4), 'To binary string');

            $this->assertEquals(1, MMaps_Tiles_fromBinaryString('1'), 'From binary string');
            $this->assertEquals(3, MMaps_Tiles_fromBinaryString('11'), 'From binary string');
            $this->assertEquals(5, MMaps_Tiles_fromBinaryString('101'), 'From binary string');
            $this->assertEquals(9, MMaps_Tiles_fromBinaryString('1001'), 'From binary string');
        }
        
        function test_yahoo_strings()
        {
            $this->assertEquals('[0,0,1]', json_encode(MMaps_Tiles_fromYahooRoad(0, 0, 17)), 'fromYahooRoad');
            $this->assertEquals('[10507,25322,16]', json_encode(MMaps_Tiles_fromYahooRoad(10507, 7445, 2)), 'fromYahooRoad');
            $this->assertEquals('[10482,25333,16]', json_encode(MMaps_Tiles_fromYahooRoad(10482, 7434, 2)), 'fromYahooRoad');

            $this->assertEquals('[0,0,17]', json_encode(MMaps_Tiles_toYahooRoad(0, 0, 1)), 'toYahooRoad');
            $this->assertEquals('[10507,7445,2]', json_encode(MMaps_Tiles_toYahooRoad(10507, 25322, 16)), 'toYahooRoad');
            $this->assertEquals('[10482,7434,2]', json_encode(MMaps_Tiles_toYahooRoad(10482, 25333, 16)), 'toYahooRoad');

            $this->assertEquals('[0,0,1]', json_encode(MMaps_Tiles_fromYahooAerial(0, 0, 17)), 'fromYahooAerial');
            $this->assertEquals('[10507,25322,16]', json_encode(MMaps_Tiles_fromYahooAerial(10507, 7445, 2)), 'fromYahooAerial');
            $this->assertEquals('[10482,25333,16]', json_encode(MMaps_Tiles_fromYahooAerial(10482, 7434, 2)), 'fromYahooAerial');

            $this->assertEquals('[0,0,17]', json_encode(MMaps_Tiles_toYahooAerial(0, 0, 1)), 'toYahooAerial');
            $this->assertEquals('[10507,7445,2]', json_encode(MMaps_Tiles_toYahooAerial(10507, 25322, 16)), 'toYahooAerial');
            $this->assertEquals('[10482,7434,2]', json_encode(MMaps_Tiles_toYahooAerial(10482, 25333, 16)), 'toYahooAerial');
        }
        
        function test_microsoft_strings()
        {
            $this->assertEquals('[0,0,1]', json_encode(MMaps_Tiles_fromMicrosoftRoad('0')), 'fromMicrosoftRoad');
            $this->assertEquals('[10507,25322,16]', json_encode(MMaps_Tiles_fromMicrosoftRoad('0230102122203031')), 'fromMicrosoftRoad');
            $this->assertEquals('[10482,25333,16]', json_encode(MMaps_Tiles_fromMicrosoftRoad('0230102033330212')), 'fromMicrosoftRoad');

            $this->assertEquals('0', MMaps_Tiles_toMicrosoftRoad(0, 0, 1), 'toMicrosoftRoad');
            $this->assertEquals('0230102122203031', MMaps_Tiles_toMicrosoftRoad(10507, 25322, 16), 'toMicrosoftRoad');
            $this->assertEquals('0230102033330212', MMaps_Tiles_toMicrosoftRoad(10482, 25333, 16), 'toMicrosoftRoad');

            $this->assertEquals('[0,0,1]', json_encode(MMaps_Tiles_fromMicrosoftAerial('0')), 'fromMicrosoftAerial');
            $this->assertEquals('[10507,25322,16]', json_encode(MMaps_Tiles_fromMicrosoftAerial('0230102122203031')), 'fromMicrosoftAerial');
            $this->assertEquals('[10482,25333,16]', json_encode(MMaps_Tiles_fromMicrosoftAerial('0230102033330212')), 'fromMicrosoftAerial');

            $this->assertEquals('0', MMaps_Tiles_toMicrosoftAerial(0, 0, 1), 'toMicrosoftAerial');
            $this->assertEquals('0230102122203031', MMaps_Tiles_toMicrosoftAerial(10507, 25322, 16), 'toMicrosoftAerial');
            $this->assertEquals('0230102033330212', MMaps_Tiles_toMicrosoftAerial(10482, 25333, 16), 'toMicrosoftAerial');
        }
    }
        
    class Core_TestCase extends PHPUnit_TestCase
    {
        function test_points()
        {
            $p = new MMaps_Point(0, 1);

            $this->assertEquals(0, $p->x, 'Point X');
            $this->assertEquals(1, $p->y, 'Point Y');
            $this->assertEquals('(0.000, 1.000)', $p->toString(), 'Point to string');
        }

        function test_coordinates()
        {
            $c = new MMaps_Coordinate(0, 1, 2);

            $this->assertEquals(0, $c->row, 'Coordinate Row');
            $this->assertEquals(1, $c->column, 'Coordinate Column');
            $this->assertEquals(2, $c->zoom, 'Coordinate Zoom');
            $this->assertEquals('(0.000, 1.000 @2.000)', $c->toString(), 'Coordinate to string');

            $this->assertEquals('(0.000, 2.000 @3.000)', $c->zoomTo(3)->toString(), 'Coordinate zoomed to a destination');
            $this->assertEquals('(0.000, 0.500 @1.000)', $c->zoomTo(1)->toString(), 'Coordinate zoomed to a destination');

            $this->assertEquals('(-1.000, 1.000 @2.000)', $c->up()->toString(), 'Coordinate panned');
            $this->assertEquals('(0.000, 2.000 @2.000)', $c->right()->toString(), 'Coordinate panned');
            $this->assertEquals('(1.000, 1.000 @2.000)', $c->down()->toString(), 'Coordinate panned');
            $this->assertEquals('(0.000, 0.000 @2.000)', $c->left()->toString(), 'Coordinate panned');
        }
    }
    
    class Geo_TestCase extends PHPUnit_TestCase
    {
        function test_transformations()
        {
            $t = new MMaps_Transformation(0, 1, 0, 1, 0, 0);
            $p = new MMaps_Point(0, 1);
            
            $_p = $t->transform($p);
            $this->assertEquals(1, $_p->x, 'Point X');
            $this->assertEquals(0, $_p->y, 'Point Y');
            
            $__p = $t->untransform($_p);
            $this->assertEquals($p->x, $__p->x, 'Point X');
            $this->assertEquals($p->y, $__p->y, 'Point Y');

            $t = new MMaps_Transformation(1, 0, 1, 0, 1, 1);
            $p = new MMaps_Point(0, 0);
            
            $_p = $t->transform($p);
            $this->assertEquals(1, $_p->x, 'Point X');
            $this->assertEquals(1, $_p->y, 'Point Y');
            
            $__p = $t->untransform($_p);
            $this->assertEquals($p->x, $__p->x, 'Point X');
            $this->assertEquals($p->y, $__p->y, 'Point Y');
        }

        function test_projections()
        {
            $m = new MMaps_Mercator_Projection(10);

            $c = $m->locationCoordinate(new MMaps_Location(0, 0));
            $this->assertEquals('(-0.000, 0.000 @10.000)', $c->toString(), 'Location to Coordinate');

            $l = $m->coordinateLocation(new MMaps_Coordinate(0, 0, 10));
            $this->assertEquals('(0.000, 0.000)', $l->toString(), 'Coordinate to Location');

            $c = $m->locationCoordinate(new MMaps_Location(37, -122));
            $this->assertEquals('(0.696, -2.129 @10.000)', $c->toString(), 'Location to Coordinate');

            $l = $m->coordinateLocation(new MMaps_Coordinate(0.696, -2.129, 10.000));
            $this->assertEquals('(37.001, -121.983)', $l->toString(), 'Coordinate to Location');
        }
    }
    
    class Map_TestCase extends PHPUnit_TestCase
    {
        function test_constructor()
        {
            $m = new Modest_Map(new MMaps_OpenStreetMap_Provider(), new MMaps_Point(600, 600), new MMaps_Coordinate(3165, 1313, 13), new MMaps_Point(-144, -94));

            $p = $m->locationPoint(new MMaps_Location(37.804274, -122.262940));
            $this->assertEquals('(370.724, 342.549)', $p->toString(), 'Map locationPoint');
            
            $l = $m->pointLocation($p);
            $this->assertEquals('(37.804, -122.263)', $l->toString(), 'Map pointLocation');
        }

        function test_map_by_center_zoom()
        {
            $c = new MMaps_Location(37.804274, -122.262940);
            $z = 12;
            $d = new MMaps_Point(800, 600);
            $m = MMaps_mapByCenterZoom(new MMaps_OpenStreetMap_Provider(), $c, $z, $d);
            
            $this->assertEquals('(800.000, 600.000)', $m->dimensions->toString(), 'Map dimensions');
            $this->assertEquals('(1582.000, 656.000 @12.000)', $m->coordinate->toString(), 'Map coordinate');
            $this->assertEquals('(-235.000, -196.000)', $m->offset->toString(), 'Map offset');
        }

        function test_map_by_extent()
        {
            $sw = new MMaps_Location(36.893326, -123.533554);
            $ne = new MMaps_Location(38.864246, -121.208153);
            $d = new MMaps_Point(800, 600);
            $m = MMaps_mapByExtent(new MMaps_OpenStreetMap_Provider(), $sw, $ne, $d);

            $this->assertEquals('(800.000, 600.000)', $m->dimensions->toString(), 'Map dimensions');
            $this->assertEquals('(98.000, 40.000 @8.000)', $m->coordinate->toString(), 'Map coordinate');
            $this->assertEquals('(-251.000, -218.000)', $m->offset->toString(), 'Map offset');

            $se = new MMaps_Location(36.893326, -121.208153);
            $nw = new MMaps_Location(38.864246, -123.533554);
            $d = new MMaps_Point(1600, 1200);
            $m = MMaps_mapByExtent(new MMaps_OpenStreetMap_Provider(), $se, $nw, $d);

            $this->assertEquals('(1600.000, 1200.000)', $m->dimensions->toString(), 'Map dimensions');
            $this->assertEquals('(197.000, 81.000 @9.000)', $m->coordinate->toString(), 'Map coordinate');
            $this->assertEquals('(-246.000, -179.000)', $m->offset->toString(), 'Map offset');
        }

        function test_map_by_extent_zoom()
        {
            $sw = new MMaps_Location(36.893326, -123.533554);
            $ne = new MMaps_Location(38.864246, -121.208153);
            $z = 10;
            $m = MMaps_mapByExtentZoom(new MMaps_OpenStreetMap_Provider(), $sw, $ne, $z);

            $this->assertEquals('(1693.000, 1818.000)', $m->dimensions->toString(), 'Map dimensions');
            $this->assertEquals('(395.000, 163.000 @10.000)', $m->coordinate->toString(), 'Map coordinate');
            $this->assertEquals('(-236.000, -102.000)', $m->offset->toString(), 'Map offset');

            $se = new MMaps_Location(36.893326, -121.208153);
            $nw = new MMaps_Location(38.864246, -123.533554);
            $z = 9;
            $m = MMaps_mapByExtentZoom(new MMaps_OpenStreetMap_Provider(), $sw, $ne, $z);

            $this->assertEquals('(846.000, 909.000)', $m->dimensions->toString(), 'Map dimensions');
            $this->assertEquals('(197.000, 81.000 @9.000)', $m->coordinate->toString(), 'Map coordinate');
            $this->assertEquals('(-246.000, -179.000)', $m->offset->toString(), 'Map offset');
        }
    }
    
    foreach(array('Tiles', 'Core', 'Geo', 'Map') as $prefix)
    {
        $suite  = new PHPUnit_TestSuite("{$prefix}_TestCase");
        $result = PHPUnit::run($suite);
        echo $result->toString();
    }

?>