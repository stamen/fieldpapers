function data_box(Y, scan_notes_image, onChangedCallback, onSelectedCallback, onDeletedCallback)
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
          '<div class="buttons">',
            '<button class="okay">OK</button>',
            '<button class="delete">Delete</button>',
          '</div>',
        '</div>'
      ].join(''));
    
    scan_notes_image.append(node);
    
    var area = node.one('.area'),
        edge = node.one('.edge'),
        thumb1 = node.all('.thumb').item(0),
        thumb2 = node.all('.thumb').item(1),
        dead_note_outer = node.one('div.note'),
        dead_note_inner = dead_note_outer.one('span'),
        live_note = node.one('textarea.note'),
        buttons = node.one('.buttons'),
        ok_button = buttons.one('button.okay'),
        del_button = buttons.one('button.delete');
        
    box.getBounds = function()
    {
        var xmin = area.getX() - scan_notes_image.getX(),
            ymin = area.getY() - scan_notes_image.getY(),
            xmax = xmin + parseInt(area.getStyle('width')),
            ymax = ymin + parseInt(area.getStyle('height'));
        
        return {xmin: xmin, ymin: ymin, xmax: xmax, ymax: ymax};
    }
    
    box.noteText = function()
    {
        return live_note.get('value');
    }

    box.deleteBox = function()
    {
        node.remove();
    }
    
    function onMoved()
    {
        var b = box.getBounds();
        
        edge.setX(scan_notes_image.getX() + b.xmin - 4);
        edge.setY(scan_notes_image.getY() + b.ymin - 4);
        
        edge.setStyle('width', (b.xmax - b.xmin) + 2 + 'px');
        edge.setStyle('height', (b.ymax - b.ymin) + 2 + 'px');
        
        dead_note_outer.setX(scan_notes_image.getX() + b.xmin);
        dead_note_outer.setY(scan_notes_image.getY() + b.ymax + thumb_size);
        
        live_note.setX(scan_notes_image.getX() + b.xmin);
        live_note.setY(scan_notes_image.getY() + b.ymax + thumb_size);
        
        buttons.setX(scan_notes_image.getX() + b.xmin);
        buttons.setY(scan_notes_image.getY() + b.ymax + 2 * thumb_size + parseInt(live_note.getStyle('height')));
        
        if(onChangedCallback)
        {
            onChangedCallback(box.noteText(), box.getBounds());
        }
    }
    
    function onNoteChanged()
    {
        dead_note_inner.set('text', live_note.get('value'));
    
        if(onChangedCallback)
        {
            onChangedCallback(box.noteText(), box.getBounds());
        }
    }
    
    function updateThumbs()
    {
        var b = box.getBounds();
        
        if(flipped) {
            thumb1.setXY([scan_notes_image.getX() + b.xmin,
                          scan_notes_image.getY() + b.ymax - thumb_size]);

            thumb2.setXY([scan_notes_image.getX() + b.xmax - thumb_size,
                          scan_notes_image.getY() + b.ymin]);
        
        } else {
            thumb1.setXY([scan_notes_image.getX() + b.xmin,
                          scan_notes_image.getY() + b.ymin]);

            thumb2.setXY([scan_notes_image.getX() + b.xmax - thumb_size,
                          scan_notes_image.getY() + b.ymax - thumb_size]);
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
    
    function deselectBox()
    {
        onNoteChanged();
        
        node.replaceClass('active', 'inactive');
    }
    
    function deleteBox()
    {
        if(confirm('Really delete?'))
        {
            node.remove();
            
            if(onDeletedCallback)
            {
                onDeletedCallback(box);
            }
        }
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
    
    ok_button.on('click', deselectBox);
    del_button.on('click', deleteBox);
    
    var _drag;
    
    _drag = new Y.DD.Drag({ node: area });
    _drag = _drag.plug(Y.Plugin.DDConstrained, { constrain2node: scan_notes_image });
    _drag.after('drag', updateThumbs);
    _drag.on('start', onSelected);

    _drag = new Y.DD.Drag({ node: thumb1 });
    _drag = _drag.plug(Y.Plugin.DDConstrained, { constrain2node: scan_notes_image });
    _drag.after('drag', updateArea);
    _drag.on('start', onSelected);

    _drag = new Y.DD.Drag({ node: thumb2 });
    _drag = _drag.plug(Y.Plugin.DDConstrained, { constrain2node: scan_notes_image });
    _drag.after('drag', updateArea);
    _drag.on('start', onSelected);

    live_note.after('blur', onNoteChanged);
    live_note.after('change', onNoteChanged);
    
    return box;
}

function data_row(Y, scan_note_rows_tbody, onDeletedCallback)
{
    var node = Y.Node.create([
        '<tr>',
        '<td class="delete"><button>Delete</button></td>',
        '<td class="note"></td>',
        '<td class="n"></td>',
        '<td class="w"></td>',
        '<td class="s"></td>',
        '<td class="e"></td>',
        '</tr>'
      ].join(''));
    
    scan_note_rows_tbody.append(node);
    
    var row = {},
        del_button = node.one('.delete button'),
        cell_note = node.one('.note'),
        cell_north = node.one('.n'),
        cell_south = node.one('.s'),
        cell_west = node.one('.w'),
        cell_east = node.one('.e');
    
    row.describeBox = function(note, bounds)
    {
        cell_note.set('text', note);

        cell_north.set('text', bounds[0].toFixed(6));
        cell_south.set('text', bounds[2].toFixed(6));
        cell_west.set('text', bounds[1].toFixed(6));
        cell_east.set('text', bounds[3].toFixed(6));
    }
    
    row.deleteRow = function()
    {
        node.remove();
    }
    
    function deleteRow()
    {
        if(confirm('Really delete?'))
        {
            node.remove();
            
            if(onDeletedCallback)
            {
                onDeletedCallback(row);
            }
        }
    }
    
    del_button.on('click', deleteRow);
    
    return row;
}

function setup_data_boxes(Y, bounds)
{
    var box_rows = [];

    var scan_notes_image = Y.one('#scan-notes-image'),
        scan_note_rows = Y.one('#scan-note-rows'),
        scan_note_rows_tbody = scan_note_rows.one('tbody'),
        scan_img = scan_notes_image.one('img'),
        add_button = Y.one('#add-box');

    var img_width = scan_img.get('width'),
        img_height = scan_img.get('height');
    
    var minlat = Math.min(bounds[0], bounds[2]),
        minlon = Math.min(bounds[1], bounds[3]),
        maxlat = Math.max(bounds[0], bounds[2]),
        maxlon = Math.max(bounds[1], bounds[3]),
        latspan = minlat - maxlat,
        lonspan = maxlon - minlon;

    function foregroundBox(node)
    {
        var boxes = scan_notes_image.all('.drag-box');
        
        if(boxes.indexOf(node) < boxes.size() - 1)
        {
            // move it to the front if it's not there already.
            scan_notes_image.append(node);
        }
    }
    
    function hideBoxes()
    {
        scan_notes_image.get('children').replaceClass('active', 'inactive');
    }
    
    function boxBounds(bounds)
    {
        return [maxlat + latspan * (bounds.ymin / img_height),
                minlon + lonspan * (bounds.xmin / img_width),
                maxlat + latspan * (bounds.ymax / img_height),
                minlon + lonspan * (bounds.xmax / img_width)];
    }
    
    function addBox()
    {
        hideBoxes();
        
        function onBoxChanged(note_text, box_bounds)
        {
            row.describeBox(note_text, boxBounds(box_bounds));
        }
        
        var row = data_row(Y, scan_note_rows_tbody, deleteRow),
            box = data_box(Y, scan_notes_image, onBoxChanged, foregroundBox, deleteBox);
        
        box_rows.push({box: box, row: row});
    }
    
    function deleteBox(box)
    {
        for(var i = 0; i < box_rows.length; i++)
        {
            if(box_rows[i].box == box)
            {
                box_rows[i].row.deleteRow();
                box_rows.splice(i, 1);
                return;
            }
        }
    }
    
    function deleteRow(row)
    {
        for(var i = 0; i < box_rows.length; i++)
        {
            if(box_rows[i].row == row)
            {
                box_rows[i].box.deleteBox();
                box_rows.splice(i, 1);
                return;
            }
        }
    }
    
    scan_notes_image.setStyle('width', img_width + 'px');
    scan_notes_image.setStyle('height', img_height + 'px');
    scan_note_rows.setStyle('width', img_width + 'px');
    
    scan_img.on('click', hideBoxes);
    
    add_button.after('click', addBox);
}
