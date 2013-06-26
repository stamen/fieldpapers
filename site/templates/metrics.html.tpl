<!DOCTYPE html>
<html lang="en">
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8">
    <title>Metrics - fieldpapers.org</title>
    <link rel="stylesheet" href="{$base_dir}/css/fieldpapers.css" type="text/css">
    <script src="http://d3js.org/d3.v3.min.js" charset="utf-8"></script>
    <style>
        {literal}
        .bar {
            display: inline-block;
            background: #000;
            margin-right: 1px;
            vertical-align: bottom;
            width: 2px;
        }
        #chart-wrap{
            width: auto;
            overflow:scroll;
        }
        #chart{
            width: auto;
            height: auto;
            white-space: nowrap;
            margin-bottom: 20px;
        }
        {/literal}

    </style>
</head>
<body>
<div id='chart-wrap'><div id="chart"></div></div>
<script>


var metric_data = {$metric_data};
{literal}
metric_data.forEach(function(m){
    m.composed = new Date(m.composed);
    m.created = new Date(m.created);
    m.composed_ts = +m.composed;
    m.created_ts = +m.created; 
});

metric_data.sort(function(a,b){
    return b.created_ts - a.created_ts;
});
var startTime = metric_data[0].created_ts;
var endTime = metric_data[metric_data.length-1].created_ts;
var days = {};
var day = 60 * 60 * 24;


function convertStart(t){
    var d = new Date(t);
    d.setHours(0);
    d.setMinutes(0);
    d.setSeconds(0);
    d.setMilliseconds(0);
    return +d;
}
function convertEnd(t){
  
    var d = new Date(t);
    d.setHours(23);
    d.setMinutes(59);
    d.setSeconds(59);
    d.setMilliseconds(9999);
    return d;
 
}

var start = convertStart(startTime),
    end = start + day;
days[start] = [];
function binByTime(unitOfTime){
    metric_data.forEach(function(m){
        var thisDay = m.created_ts;
        if (thisDay >= start && thisDay < end){
            days[start].push(m);
        }else{
            start = convertStart(thisDay);
            end = start + day;
            if(!days.hasOwnProperty(start)){

                days[start] = [];
            }
            days[start].push(m);
        }
    });
    
    var arr = [];
    for(var d in days){
        arr.push({
            'ts' : d,
            'date': new Date(parseInt(d)).toString(),
            'items' : days[d]
        });
        console.log(days[d].length);  
    }
    
    arr.sort(function(a,b){
        return a.ts - b.ts;
    });

    return arr;
}
var atlases = binByTime();
var max = 0;
atlases.forEach(function(atlas){
    max = Math.max(max,atlas.items.length);
    //console.log(atlas.items.length);
    //console.log(new Date(parseInt(atlas.ts)));
});

var chartElm = d3.select('#chart');
var min = d3.min(atlases, function(atlas){return atlas.items.length;});
//var max = d3.max(atlases, function(atlas){return atlas.items.length;});

var scale = d3.scale.linear().domain([min,max]).range([0,400]);
var fmtTime = d3.time.format("%x");
chartElm.selectAll('.bar')
.data(atlases)
.enter()
.append('div')
.attr('class','bar')
.style('height', function(d){
    return scale(d.items.length) + 'px';
})
.attr('title', function(d){
    return fmtTime(new Date(parseInt(d.ts))) + ", Count: " + d.items.length;
})
.on('mouseover',function(){

})
.on('mouseout',function(){

});


{/literal}
</script>
</body>
</html>

