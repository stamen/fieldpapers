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
        note = new Y.Node(document.createElement('textarea'));
    
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
    
    note.addClass('note');

    bbox.append(node);
    node.append(edge);
    node.append(area);
    node.append(thumb1);
    node.append(thumb2);
    node.append(note);

    box.getBounds = function()
    {
        var xmin = area.getX(),
            ymin = area.getY(),
            xmax = xmin + parseInt(area.getStyle('width')),
            ymax = ymin + parseInt(area.getStyle('height'));
        
        return {xmin: xmin, ymin: ymin, xmax: xmax, ymax: ymax};
    }
    
    box.noteText = function()
    {
        return note.get('text');
    }
    
    function onMoved()
    {
        var b = box.getBounds();

        edge.setX(b.xmin - 4);
        edge.setY(b.ymin - 4);
        
        edge.setStyle('width', (b.xmax - b.xmin) + 2 + 'px');
        edge.setStyle('height', (b.ymax - b.ymin) + 2 + 'px');
        
        note.setX(b.xmin);
        note.setY(b.ymax + thumb_size);
        
        if(onChangedCallback)
        {
            onChangedCallback(box);
        }
    }
    
    function onNoteChanged()
    {
        if(onChangedCallback)
        {
            onChangedCallback(box);
        }
    }
    
    function updateThumbs()
    {
        var b = box.getBounds();
        
        if(flipped) {
            thumb1.setXY([b.xmin, b.ymax - thumb_size]);
            thumb2.setXY([b.xmax - thumb_size, b.ymin]);
        
        } else {
            thumb1.setXY([b.xmin, b.ymin]);
            thumb2.setXY([b.xmax - thumb_size, b.ymax - thumb_size]);
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
        note.focus();
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

    note.after('change', onNoteChanged);
    
    return box;
}

function setup_dragboxes(Y, bounds)
{
    var bbox = Y.one('#scan-notes'),
        scan = bbox.one('img');

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

    function add_box()
    {
        hide_boxes();
        dragbox(Y, bbox, undefined, foregroundBox);
    }
    
    bbox.setStyle('width', scan.get('width') + 'px');
    bbox.setStyle('height', scan.get('height') + 'px');
    
    scan.on('click', hide_boxes);
    
    Y.one('#add-box').after('click', add_box);
}
