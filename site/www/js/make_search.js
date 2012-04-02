function changeFormAction(index)
{
    var mbtiles_info = document.getElementById('mbtiles_selection').options[index].value;
    
    var mbtiles_info = mbtiles_info.split('_');

    var id = mbtiles_info[0];
    var y = mbtiles_info[1];
    var x = mbtiles_info[2];
    var z = mbtiles_info[3];

    document.getElementById('mbtiles_form').action = base_url + '/make-step2-geography.php?\mbtiles_id=' + id + '&coordinates=' + y + '/' + x + '/' + z;
}