function leafletDatatable(table, panesShow, panesHide) {                
    // display map container
    $('#leaflet-map-one').css({'display': 'flex'});
    // leaflet map:
    var latStart = document.body.querySelectorAll('.map-coordinates')[0].getAttribute('lat');
    var longStart = document.body.querySelectorAll('.map-coordinates')[0].getAttribute('long');
    var mymap = L.map('leaflet-map-one').setView([latStart,longStart], 2);
    
    var tiles = L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: 'Map data &amp;copy; <a href="https://www.openstreetmap.org/">OpenStreetMap</a> contributors, <a href="https://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="https://www.openstreetmap.org/">OpenStreetMap</a>',
        maxZoom: 18,
        zIndex: 1
    }).addTo(mymap);

    mymap.addControl(new L.Control.Fullscreen());

    var cfg = {
        // radius should be small ONLY if scaleRadius is true (or small radius is intended)
        // if scaleRadius is false it will be the constant radius used in pixels
        "radius": 1,
        "maxOpacity": .5,
        // scales the radius based on map zoom
        "scaleRadius": true,
        // if set to false the heatmap uses the global maximum for colorization
        // if activated: uses the data maximum within the current map boundaries
        //   (there will always be a red spot with useLocalExtremas true)
        "useLocalExtrema": true,
        // which field name in your data represents the latitude - default "lat"
        latField: 'lat',
        // which field name in your data represents the longitude - default "lng"
        lngField: 'lng',
        // which field name in your data represents the data value - default "value"
        valueField: 'count'
    };
    
    /* create labels for each coordinate existing lat long coordinate */
    var markers = L.markerClusterGroup();
    var markers_heat = new HeatmapOverlay(cfg);

    var heatmap_data = getPlaceCountCoords();
    markers_heat.setData({
        max: 8,
        data: heatmap_data
    });

    var objects = new L.GeoJSON.AJAX([`geo/${table}.geojson`], {onEachFeature:popUp});
    // objects.on('data:loaded', function () {
    //     markers.addLayer(objects);
    //     mymap.addLayer(markers);
    //     try {
    //         mymap.fitBounds(markers.getBounds());
    //     } catch (err) {
    //         console.log(err);
    //     }
    // });
               
    // variable id #tableOne must match table id in html
    var tableOne = $('#' + table)
    .DataTable({
        "language": {
        "url": "https://cdn.datatables.net/plug-ins/1.10.19/i18n/English.json"
            },
        dom: 'PfpBrtip',
        buttons:['copy', 'excel', 'pdf'],
        "lengthMenu":[25, 50, 75, 100, "All"],
        responsive: true,
        orderCellsTop: true,
        "pageLength": 50,
        keepConditions: true,
        columnDefs: [
            {
                searchPanes: {
                    show: true
                },
                targets: panesShow
            },
            {
                searchPanes: {
                    show: false
                },
                targets: panesHide
            }
        ],
    });
    
    tableOne.on('search.dt', function() {
        var value = $('.dataTables_filter input').val();
        if (value.length != 0) {
            markers.clearLayers();
            getCoordinates();
            mymap.addLayer(markers);
            try {
                mymap.fitBounds(markers.getBounds());
            } catch (err) {
                console.log(err);
            }
        } else {
            markers.clearLayers();
            var objects = new L.GeoJSON.AJAX([`geo/${table}.geojson`], {onEachFeature:popUp});
            objects.on('data:loaded', function () {
                markers.addLayer(objects);
                mymap.addLayer(markers);
                try {
                    mymap.fitBounds(markers.getBounds());
                } catch (err) {
                    console.log(err);
                }
            });
        }
    });
    
    tableOne.on('page.dt', function() {
        markers.clearLayers();
        getCoordinates();
        mymap.addLayer(markers);
        try {
            mymap.fitBounds(markers.getBounds());
        } catch (err) {
            console.log(err);
        }
    });

    var baseLayers = {
        'Map': tiles
    };
    var overlays = {
        "Places Cluster": markers,
        "Places": objects,
        "Heatmap": markers_heat
    };
    var layerControl = L.control.layers(baseLayers, overlays).addTo(mymap);

    $("#tableReload-wrapper").on('click', function() {
        var objects = new L.GeoJSON.AJAX([`geo/${table}.geojson`], {onEachFeature:popUp});
        markers.clearLayers();
        objects.on('data:loaded', function () {
            markers.addLayer(objects);
            mymap.addLayer(markers);
            try {
                mymap.fitBounds(markers.getBounds());
            } catch (err) {
                console.log(err);
            }
        });
    });

    function getCoordinates() {      
        document.body.querySelectorAll('.map-coordinates').forEach(function(node) {
            var lat = node.getAttribute('lat');
            var long = node.getAttribute('long');
            var id = node.getAttribute('id');
            var country = node.getAttribute('data-country');
            var place = `Placename: ${node.getAttribute('subtitle')}, ${country}<br/><a href="${id}.html">Read more</a>`;
            markers.addLayer(L.marker([lat,long]).bindPopup(place));
        });       
    }

    function getPlaceCountCoords() {     
        var plc_qty = []; 
        document.body.querySelectorAll('.map-coordinates').forEach(function(node) {
            var lat = node.getAttribute('lat');
            var long = node.getAttribute('long');
            var qty = node.getAttribute('data-count');
            var plc = {
                "lat": parseFloat(lat),
                "lng": parseFloat(long),
                "count": parseInt(qty)
            };

            if (qty.length > 0) {
                plc_qty.push(plc);
            }
            
        });
        return plc_qty;
    }

    function popUp(f, l) {
        
        var out = [];
        if (f.properties['title_plc']) {
            var plc = f.properties['title_plc'];
            var org = f.properties['title'];
            var id = f.properties['id_plc']
        } else {
            var plc = f.properties['title'];
        } 

        if (org) {
            out.push(org); 
        }

        if (id) {
            out.push(`<a href='${id}.html'>${plc}</a>` + ', ' + f.properties['country_code']);
        } else {
            out.push(plc + ', ' + f.properties['country_code']);
        }

        out.push(`<a href='${f.properties['id']}.html'>Read more</a>`);
        l.bindPopup(out.join("<br />"));
    }
}
