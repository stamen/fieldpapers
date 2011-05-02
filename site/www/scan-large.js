function dragbox(Y, bbox, onChangedCallback, onSelectedCallback)
{
    var box = {},
        thumb_size = 8,
        flipped = false;

   /*
    * Prepare DOM.
    */
    var node = Y.Node.create([
        '<div class="drag-box">',
          '<div class="edge"></div>',
          '<div class="area" style="left: 10px; top: 10px; width: 50px; height: 50px;"></div>',
          '<div class="thumb" style="width: '+thumb_size+'px; height: '+thumb_size+'px;"></div>',
          '<div class="thumb" style="width: '+thumb_size+'px; height: '+thumb_size+'px;"></div>',
          '<div class="note">',
            '<span></span>',
          '</div>',
          '<textarea class="note"></textarea>',
        '</div>'
      ].join(''));
    
    bbox.append(node);
    
    var area = node.one('.area'),
        edge = node.one('.edge'),
        thumb1 = node.all('.thumb').item(0),
        thumb2 = node.all('.thumb').item(1),
        dead_note_outer = node.one('div.note'),
        dead_note_inner = node.one('div.note span'),
        live_note = node.one('textarea.note');
        
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
        
        dead_note_outer.setX(bbox.getX() + b.xmin);
        dead_note_outer.setY(bbox.getY() + b.ymax + thumb_size);
        
        live_note.setX(bbox.getX() + b.xmin);
        live_note.setY(bbox.getY() + b.ymax + thumb_size);
        
        if(onChangedCallback)
        {
            onChangedCallback(box);
        }
    }
    
    function onNoteChanged()
    {
        dead_note_inner.set('text', live_note.get('value'));
    
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
    area.on('click', onSelected);
    dead_note_inner.on('click', onSelected);
    
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

    live_note.after('blur', onNoteChanged);
    live_note.after('change', onNoteChanged);
    
    return box;
}

function boxrow(Y, rows)
{
    var _row = Y.Node.create([
        '<tr>',
        '<td class="note"></td>',
        '<td class="n"></td>',
        '<td class="w"></td>',
        '<td class="s"></td>',
        '<td class="e"></td>',
        '</tr>'
      ].join(''));
    
    rows.append(_row);
    
    var row = {},
        cell_note = _row.one('.note'),
        cell_north = _row.one('.n'),
        cell_south = _row.one('.s'),
        cell_west = _row.one('.w'),
        cell_east = _row.one('.e');
    
    row.describeBox = function(note, bounds)
    {
        cell_note.set('text', note);

        cell_north.set('text', bounds[0].toFixed(6));
        cell_south.set('text', bounds[2].toFixed(6));
        cell_west.set('text', bounds[1].toFixed(6));
        cell_east.set('text', bounds[3].toFixed(6));
    }
    
    return row;
}

function setup_dragboxes(Y, bounds)
{
    var bbox = Y.one('#scan-notes'),
        table = Y.one('#scan-note-rows'),
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
        
        var row = boxrow(Y, Y.one('#scan-note-rows tbody'));
        
        function onBoxChanged(box)
        {
            row.describeBox(box.noteText(), boxBounds(box));
        }
        
        dragbox(Y, bbox, onBoxChanged, foregroundBox);
    }
    
    bbox.setStyle('width', img_width + 'px');
    bbox.setStyle('height', img_height + 'px');
    
    table.setStyle('width', img_width + 'px');
    
    scan.on('click', hide_boxes);
    
    button.after('click', add_box);
}
