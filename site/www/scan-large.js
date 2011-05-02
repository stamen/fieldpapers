function dragbox(Y, bbox, onChangedCallback, onSelectedCallback)
{
    var box = {},
        thumb_size = 8,
        flipped = false;

   /*
    * Prepare DOM.
    */
    var node = new Y.Node(document.createElement('div')),
        edge = new Y.Node(document.createElement('div')),
        area = new Y.Node(document.createElement('div')),
        thumb1 = new Y.Node(document.createElement('div')),
        thumb2 = new Y.Node(document.createElement('div')),
        dead_note = new Y.Node(document.createElement('div')),
        live_note = new Y.Node(document.createElement('textarea'));
    
    node.addClass('drag-box');
    
    edge.addClass('edge');

    area.addClass('area');
    area.setStyle('left', '10px');
    area.setStyle('top', '10px');
    area.setStyle('width', '50px');
    area.setStyle('height', '50px');

    thumb1.addClass('thumb');
    thumb1.setStyle('width', thumb_size + 'px');
    thumb1.setStyle('height', thumb_size + 'px');
    
    thumb2.addClass('thumb');
    thumb2.setStyle('width', thumb_size + 'px');
    thumb2.setStyle('height', thumb_size + 'px');
    
    dead_note.addClass('note');
    live_note.addClass('note');

    bbox.append(node);
    node.append(edge);
    node.append(area);
    node.append(thumb1);
    node.append(thumb2);
    node.append(dead_note);
    node.append(live_note);

    box.getBounds = function()
    {
        var xmin = area.getX() - bbox.getX(),
            ymin = area.getY() - bbox.getY(),
            xmax = xmin + parseInt(area.getStyle('width')),
            ymax = ymin + parseInt(area.getStyle('height'));
        
        return {xmin: xmin, ymin: ymin, xmax: xmax, ymax: ymax};
    }
    
    box.noteText = function()
    {
        return live_note.get('value');
    }
    
    function onMoved()
    {
        var b = box.getBounds();
        
        edge.setX(bbox.getX() + b.xmin - 4);
        edge.setY(bbox.getY() + b.ymin - 4);
        
        edge.setStyle('width', (b.xmax - b.xmin) + 2 + 'px');
        edge.setStyle('height', (b.ymax - b.ymin) + 2 + 'px');
        
        dead_note.setX(bbox.getX() + b.xmin);
        dead_note.setY(bbox.getY() + b.ymax + thumb_size);
        
        live_note.setX(bbox.getX() + b.xmin);
        live_note.setY(bbox.getY() + b.ymax + thumb_size);
        
        if(onChangedCallback)
        {
            onChangedCallback(box);
        }
    }
    
    function onNoteChanged()
    {
        dead_note.set('text', live_note.get('value'));
    
        if(onChangedCallback)
        {
            onChangedCallback(box);
        }
    }
    
    function updateThumbs()
    {
        var b = box.getBounds();
        
        if(flipped) {
            thumb1.setXY([bbox.getX() + b.xmin, bbox.getY() + b.ymax - thumb_size]);
            thumb2.setXY([bbox.getX() + b.xmax - thumb_size, bbox.getY() + b.ymin]);
        
        } else {
            thumb1.setXY([bbox.getX() + b.xmin, bbox.getY() + b.ymin]);
            thumb2.setXY([bbox.getX() + b.xmax - thumb_size,
                          bbox.getY() + b.ymax - thumb_size]);
        }
        
        onMoved();
    }
    
    function updateArea()
    {
        var xmin = Math.min(thumb1.getX(), thumb2.getX()),
            ymin = Math.min(thumb1.getY(), thumb2.getY()),
            xmax = Math.max(thumb1.getX(), thumb2.getX()) + thumb_size,
            ymax = Math.max(thumb1.getY(), thumb2.getY()) + thumb_size;
        
        area.setXY([xmin, ymin]);
        area.setStyle('width', (xmax - xmin) + 'px');
        area.setStyle('height', (ymax - ymin) + 'px');
        
        flipped = ((thumb1.getX() < thumb2.getX() && thumb1.getY() > thumb2.getY())
                || (thumb1.getX() > thumb2.getX() && thumb1.getY() < thumb2.getY()));
        
        onMoved();
    }
    
    function onSelected()
    {
        if(onSelectedCallback)
        {
            onSelectedCallback(node);
        }
        
        node.siblings().replaceClass('active', 'inactive');
        node.replaceClass('inactive', 'active');
        live_note.focus();
    }
    
   /*
    * Initial position.
    */
    updateThumbs();

   /*
    * Connect drag behaviors.
    */
    node.on('click', onSelected);
    
    var _drag;
    
    _drag = new Y.DD.Drag({ node: area });
    _drag = _drag.plug(Y.Plugin.DDConstrained, { constrain2node: bbox });
    _drag.after('drag', updateThumbs);
    _drag.on('start', onSelected);

    _drag = new Y.DD.Drag({ node: thumb1 });
    _drag = _drag.plug(Y.Plugin.DDConstrained, { constrain2node: bbox });
    _drag.after('drag', updateArea);
    _drag.on('start', onSelected);

    _drag = new Y.DD.Drag({ node: thumb2 });
    _drag = _drag.plug(Y.Plugin.DDConstrained, { constrain2node: bbox });
    _drag.after('drag', updateArea);
    _drag.on('start', onSelected);

    live_note.after('change', onNoteChanged);
    
    return box;
}

function setup_dragboxes(Y, bounds)
{
    var bbox = Y.one('#scan-notes'),
        scan = bbox.one('img'),
        button = Y.one('#add-box'),
        blather = Y.one('#blather');

    var img_width = scan.get('width'),
        img_height = scan.get('height');
    
    var minlat = Math.min(bounds[0], bounds[2]),
        minlon = Math.min(bounds[1], bounds[3]),
        maxlat = Math.max(bounds[0], bounds[2]),
        maxlon = Math.max(bounds[1], bounds[3]),
        latspan = minlat - maxlat,
        lonspan = maxlon - minlon;

    function foregroundBox(node)
    {
        var boxes = bbox.all('.drag-box');
        
        if(boxes.indexOf(node) < boxes.size() - 1)
        {
            // move it to the front if it's not there already.
            bbox.append(node);
        }
    }
    
    function hide_boxes()
    {
        bbox.get('children').replaceClass('active', 'inactive');
    }
    
    function boxBounds(box)
    {
        var b = box.getBounds();
        
        return [maxlat + latspan * (b.ymin / img_height),
                minlon + lonspan * (b.xmin / img_width),
                maxlat + latspan * (b.ymax / img_height),
                minlon + lonspan * (b.xmax / img_width)];
    }
    
    function onBoxChanged(box)
    {
        blather.set('text', 'box: ' + box.noteText() + ' at ' + boxBounds(box).toString());
    }

    function add_box()
    {
        hide_boxes();
        dragbox(Y, bbox, onBoxChanged, foregroundBox);
    }
    
    bbox.setStyle('width', img_width + 'px');
    bbox.setStyle('height', img_height + 'px');
    
    scan.on('click', hide_boxes);
    
    button.after('click', add_box);
}
