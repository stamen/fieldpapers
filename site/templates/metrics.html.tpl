<!DOCTYPE html>
<html lang="en">
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8">
    <title>Metrics - fieldpapers.org</title>
    <link rel="stylesheet" href="{$base_dir}/css/fieldpapers.css" type="text/css"> 
<!--    <link rel="stylesheet" href="../www/css/fieldpapers.css" type="text/css">-->
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
		#chart-wrap h2 {
			text-align: center;	
		}
        #chart{
            width: auto;
            height: auto;
            white-space: nowrap;
            margin-bottom: 20px;
        }
		#pies {
			text-align: center;
		}
		.pie {
			display: inline-block;
		}
		.pie text {
			fill: #fff;
		}
        {/literal}

    </style>
</head>
<body>

    {include file="navigation.htmlf.tpl"}

	<div class="container">
    	<h2>Metrics!</h2>
        <p>This is a <em>bone simple</em> graph of atlases created each day. The giant peak you can see on the left there is our launch day, 30 May 2012. That's 440 atlases. </p>
		<div id="chart-wrap">
        	<div id="chart"></div>
            <h2>Atlases per Day</h2>
        </div>

        <div id="pies">
            <div id="orientationPie" class="pie">
            	<h3>Orientation</h3>
            </div>
    
            <div id="layoutPie" class="pie">
            	<h3>Page Layout</h3>
            </div>
    
            <div id="providerPie" class="pie">
            	<h3>Map Provider</h3>
            </div>
        </div>

<script>

/* make buckets */
var metric_data = {$metric_data};
var providers = {$providers};
{literal}
metric_data.forEach(function(m){
    m.composed = new Date(m.composed);
    m.created = new Date(m.created);
    m.composed_ts = +m.composed;
    m.created_ts = +m.created; 
});

/* sort first to last */
metric_data.sort(function(a,b){
    return b.created_ts - a.created_ts;
});

/* make day buckets */
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
        //console.log(days[d].length);  
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

/* draw chart */
var chartElm = d3.select('#chart');
var min = d3.min(atlases, function(atlas){return atlas.items.length;});
//var max = d3.max(atlases, function(atlas){return atlas.items.length;});

var scale = d3.scale.linear().domain([min,max]).range([0,300]);
//var axis = d3.svg.axis();
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

//ORIENTATION PIE

var data = d3.nest()
	.key(function(d) { return d.orientation; })
	.rollup(function(d) {
		return d.length;
	})
	.entries(metric_data)
	.filter(function(d) { return d.key; });

var width = 310,
    height = 310,
    radius = Math.min(width, height) / 2;

var color = d3.scale.ordinal()
	.range(["#666", "#888", "#aaa", "#ccc", "#eee"]);

var arc = d3.svg.arc()
    .outerRadius(radius - 10)
    .innerRadius(0);

var pie = d3.layout.pie()
    .sort(null)
    .value(function(d) { return d.values; });

var svg = d3.select("#orientationPie").append("svg")
    .attr("width", width)
    .attr("height", height)
	.append("g")
    	.attr("transform", "translate(" + width / 2 + "," + height / 2 + ")");

var g = svg.selectAll(".arc")
	.data(pie(data))
	.enter()
	.append("g")
		.attr("class", "arc");

g.append("path")
	.attr("d", arc)
	.style("fill", function(d) { return color(d.data.key); });

var numberFormat = d3.format(",");

g.append("text")
	.attr("transform", function(d) { return "translate(" + arc.centroid(d) + ")"; })
	.attr("dy", ".35em")
	.style("text-anchor", "middle")
	.text(function(d) { return numberFormat(d.data.values) + " " + d.data.key; });

//LAYOUT PIE

var data = d3.nest()
	.key(function(d) { return d.layout; })
	.rollup(function(d) {
		return d.length;
	})
	.entries(metric_data)
	.filter(function(d) { return d.key; });

var color = d3.scale.ordinal()
	.range(["#666", "#888", "#aaa", "#ccc", "#eee"]);

var arc = d3.svg.arc()
    .outerRadius(radius - 10)
    .innerRadius(0);

var pie = d3.layout.pie()
    .sort(null)
    .value(function(d) { return d.values; });

var svg = d3.select("#layoutPie").append("svg")
    .attr("width", width)
    .attr("height", height)
	.append("g")
    	.attr("transform", "translate(" + width / 2 + "," + height / 2 + ")");

var g = svg.selectAll(".arc")
	.data(pie(data))
	.enter()
	.append("g")
		.attr("class", "arc");

g.append("path")
	.attr("d", arc)
	.style("fill", function(d) { return color(d.data.key); });

var numberFormat = d3.format(",");

g.append("text")
	.attr("transform", function(d) { return "translate(" + arc.centroid(d) + ")"; })
	.attr("dy", ".35em")
	.style("text-anchor", "middle")
	.text(function(d) { return numberFormat(d.data.values) + " " + d.data.key; });

//PROVIDERS PIE

var data = d3.nest()
	.key(function(d) { return d.provider; })
	.rollup(function(d) {
		return d.length;
	})
	.entries(metric_data)
	.filter(function(d) { return d.key && providers[d.key]; })
	.sort(function(a, b) {
		return d3.descending(a.values, b.values);	
	});

var color = d3.scale.ordinal()
	.range(["#666", "#888", "#aaa", "#ccc", "#eee"]);

var arc = d3.svg.arc()
    .outerRadius(radius - 10)
    .innerRadius(0);

var pie = d3.layout.pie()
    .sort(null)
    .value(function(d) { return d.values; })
	(data);

var svg = d3.select("#providerPie").append("svg")
    .attr("width", width)
    .attr("height", height)
	.append("g")
    	.attr("transform", "translate(" + width / 2 + "," + height / 2 + ")");

var g = svg.selectAll(".arc")
	.data(pie)
	.enter()
	.append("g")
		.attr("class", "arc");

g.append("path")
	.attr("d", arc)
	.style("fill", function(d) { return color(d.data.key); });

var numberFormat = d3.format(",");

var labels = svg.append("g")
	.selectAll("text")
	.data(pie)
	.enter()
	.append("text")
		.attr("transform", function(d) { return "translate(" + arc.centroid(d) + ")"; })
		.attr("dy", ".35em")
		.style("text-anchor", "middle")
		.text(function(d) { return numberFormat(d.data.values) + " " + providers[d.data.key]; });

{/literal}
</script>
	{include file="footer.htmlf.tpl"}
	</div>
</body>
</html>

