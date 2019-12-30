# Ortho DRC project

## Historical aerial surveys map long-term changes of forest cover and structure in the central Congo Basin

<style>
.legend {
	text-align: left;
	line-height: 18px;
	color: #555;
	padding: 6px 8px;
	font: 16px/18px Arial, Helvetica, sans-serif;
	background: rgba(255,255,255,0.8);
	box-shadow: 0 0 15px rgba(0,0,0,0.2);
	border-radius: 5px;
}

.legend h4 {
    margin: 0 0 5px;
	color: #777;
}

.legend i {
	width: 18px;
	height: 18px;
	float: left;
	margin-right: 8px;
	opacity: 0.7;
}

.legend .circle {
	border-radius: 50%;
	width: 10px;
	height: 10px;
	margin-top: 8px;
}


img {
  border-radius: 0%;
}

</style>

<link rel="stylesheet" href="https://unpkg.com/leaflet@1.3.4/dist/leaflet.css">
<script src="https://unpkg.com/leaflet@1.3.4/dist/leaflet.js"></script>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"></script>
<script src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.10.4/jquery-ui.min.js"></script>
<script src='https://api.mapbox.com/mapbox.js/plugins/leaflet-fullscreen/v1.0.1/Leaflet.fullscreen.min.js'></script>
<link href='https://api.mapbox.com/mapbox.js/plugins/leaflet-fullscreen/v1.0.1/leaflet.fullscreen.css' rel='stylesheet' />

Land Use and Land Cover change (LULCC) of African rainforest contribute to global carbon emissions. Yet, most historical estimates of LULCC and their carbon emissions rely on non-spatially explicity data in the pre-satellite era (< 1972).

Past studies have expanded this pre-satellite time frame with declassified satellite surveillance data or aerial surveys, but none cover the Congo Basin. Here, we use historical aerial survey photos to map the extent and structure of LULCC around Yangambi, central Congo Basin, in 1958. Our study leveraged Structure-from-Motion to generate a large orthomosaic covering 828 km^2^, counting 733 million pixels, at a sub meter resolution and geo-referenced to ~4.7 +- 4.3 m. 

Primary forest in the orthomosaic was classified with a Convolutional Neural Network Deep Learning approach. We used these data to quantify LULCC, landscape and canopy complexity and scale above ground biomass between historical and contemporary condition. We show a shift from historical highly structured industrial deforestation in 1958 (162 km^2^), to contemporary smallholder farming clearing (88 km^2^), increasing landscape fragmentation and forest edges. Efforts to quantify canopy texture and their link to carbon storage had limited to no success. 

Our analysis provides an insight in key spatial and temporal patterns of deforestation and reforestation at a multi-decadal scale and provide a historical context to land-cover and land-use change spatial patterns for past and ongoing field research in the area.

<div id="map" style="width: 600px%; height: 600px; z-index:0;"></div>


## Manuscript

<div>
  <iframe src="https://raw.githubusercontent.com/khufkens/orthodrc/master/manuscript/main.pdf" style="width:100%;height:700px;"></iframe>
</div>

## Acknowledgements

This research was supported through the Belgian Science Policy office COBECORE project (BELSPO; grant BR/175/A3/COBECORE) and from the European Union Marie Skłodowska-Curie Action (project number 797668).

<script>
      var map = L.map('map').setView([0.9, 24.5], 13);
      var baselayer =  L.tileLayer('https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',{
    	maxZoom: 16,
    	minZoom: 13,
    	subdomains:['mt0']}).addTo(map);
	var ortho = L.tileLayer('https://github.com/khufkens/COBECORE_maps/raw/master/ortho/{z}/{x}/{y}.png', {
        maxZoom: 16,
	    minZoom: 13,
        tms: false
      }).addTo(map);
      var cover = L.tileLayer('https://github.com/khufkens/COBECORE_maps/raw/master/cover/{z}/{x}/{y}.png', {
        maxZoom: 16,
	    minZoom: 13,
        tms: false
      }).addTo(map);
      L.control.layers({'Basemap':baselayer},{'orthomosaic':ortho,'forest cover':cover}).addTo(map);
      
function getColor(d) {
    return d == 4  ? '#33a02c' :
           d == 3  ? '#b2df8a' :
           d == 2  ? '#1f78b4' :
           d == 1  ? '#a6cee3' :
                     '#a6cee3' ;
}

var legend = L.control({position: 'bottomright'});

legend.onAdd = function (map) {
      var div = L.DomUtil.create('div', 'info legend'),
         grades = [1, 2, 3, 4],
         labels = ['no change','forest regrowth >1958','forest loss >2000','forest loss >1958'];
    for (var i = 0; i < grades.length; i++) {
        div.innerHTML +=
            '<i style="background:' + getColor(grades[i]) + '"></i> ' +
            labels[i] + '<br>';
    }
    return div;
};
map.addControl(new L.Control.Fullscreen());

legend.addTo(map);

</script>
