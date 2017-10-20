function initMap() {
  var minZoom = 12,
      sgCenter = { lat: 1.360270, lng: 103.815959 },
      tracks = gon.tracks,
      today = new Date().setHours(0,0,0,0),
      markers = [];

  // var infoWindow = new google.maps.InfoWindow();
  // var geocoder = new google.maps.Geocoder();

  // Set map over center of Singapore
  var map = new google.maps.Map($('#map')[0], {
    center: sgCenter,
    zoom: minZoom,
    mapTypeControl: false,
    streetViewControl: false
  });

  // Traffic and Transit layer over map
  // var trafficLayer = new google.maps.TrafficLayer();
  // trafficLayer.setMap(map);

  var transitLayer = new google.maps.TransitLayer();
  transitLayer.setMap(map);

  // Marker to be assigned
  var marker = new google.maps.Marker({
    map: map,
    anchorpoint: new google.maps.Point(0, -29)
  });

  var image = {
    url: "https://cdn3.iconfinder.com/data/icons/map/500/communication-512.png",
    scaledSize: new google.maps.Size(30, 30)
  }

  // Add markers for all saved locations
  _.each(tracks, function (track) {
    addMarker(track);
  });

  function addMarker(track) {
    position = tracks.indexOf(track);
    length = tracks.length;
    var _marker = new google.maps.Marker({
      position: { lat: track['location']['lat'] * 1, lng: track['location']['lng'] * 1 },
      map: map,
      opacity: ((position + 1.0)/length),
      title: track["track_time"],
      label: position.toString()
    });
    markers.push(_marker);
    _marker.addListener("click", function() {
      console.log("ID: "+ track["id"] + "\n" + track["track_time"]);
    });
  };

  // Set Opacity to 1.0 when time line matches track
  // $("#track_time_range").change(function() {
  //   var time = new Date(today + (this.value * 60000));
  //   _.each(markers, function (marker_track) {
  //     var created = new Date(marker_track.getTitle());
  //     if (Math.abs((created - time)/60000) <= 20.0)
  //       emphasizeMarker(marker_track);
  //     else
  //       unemphasizeMarker(marker_track);
  //   });
  // });

  // function emphasizeMarker(now_marker) {
  //   now_marker.setOpacity(1.0);
  // };

  // function unemphasizeMarker(now_marker) {
  //   now_marker.setOpacity(0.25);
  // };

  $(".trip_click").on("click", function() {
    trip_id = $(this).val();
    gon.watch("tracks", { method: "get", url: "/?trip=" + trip_id }, function(new_tracks) {
      clearCurrentTracks();
      tracks = new_tracks;
      _.each(tracks, function (track) {
        addMarker(track);
      });
      console.log("User: " + tracks[0]["user_id"] + "\nTrip: " + trip_id + "\nTrack count: " + new_tracks.length);
    });
  });

  function clearCurrentTracks() {
    _.each(markers, function(marker) {
      marker.setMap(null);
    });
  };

  // // Limit zoom on map view
  // google.maps.event.addListener(map, 'zoom_changed', function () {
  //   if (map.getZoom() < minZoom) {
  //     map.setZoom(minZoom);
  //   }
  // });

  // function addPlaceButton () {
  //   var btn = $('<div class="col-sm-2 add-place-btn"><form class="btn btn-warning">Add this place</form></div>');
  //   btn.bind('click', function (e) {
  //     if (!_.isEmpty(LOCATION)) {
  //       e.preventDefault();
  //       $.ajax({
  //         type: "POST",
  //         contentType: "application/json; charset=utf-8",
  //         url: "/api/add_places",
  //         data: JSON.stringify(LOCATION),
  //         dataType: "json",
  //         success: function (result) {
  //           addMarker(result);
  //         }
  //       });
  //     }
  //   });
  //   return btn[0];
  // };

  // $('#origin').click(function () {
  //   origin = {latitude: LOCATION['latitude'], longitude: LOCATION['longitude']}
  //   console.log(origin)
  // });

  // $('#destination').click(function () {
  //   destination = {latitude: LOCATION['latitude'], longitude: LOCATION['longitude']}
  //   console.log(destination)
  // });

  // $('#start-trip').click(function () {
  //   if (_.isEmpty(origin)) {
  //     alert("Please specify starting point");
  //   } else if (_.isEmpty(destination)) {
  //     alert("Please specify ending point");
  //   } else {
  //     $.ajax({
  //       type: "POST",
  //       contentType: "application/json; charset=utf-8",
  //       url: "/api/get_directions",
  //       data: JSON.stringify({origin, destination}),
  //       dataType: "json",
  //       success: function (result) {
  //         var duration = (Date.parse(result['end_time']) - Date.parse(result['start_time']))/60000
  //         console.log('it will take you ' + duration.toFixed(0) + ' minutes')
  //       }
  //     });
  //   }
  // });

  // map.controls[google.maps.ControlPosition.TOP_RIGHT].push(addPlaceButton());

  // var autocomplete = new google.maps.places.Autocomplete($('#pac-input')[0], restrictions);
  // autocomplete.bindTo('bounds', map);

  // autocomplete.addListener('place_changed', function() {
  //   infoWindow.close();

  //   var _place = autocomplete.getPlace();

  //   if (!_place.geometry) {
  //     window.alert("Autocomplete's returned place contains no geometry");
  //     return;
  //   }

  //   // If the place has a geometry, then present it on a map.
  //   if (_place.geometry.viewport) {
  //     map.fitBounds(_place.geometry.viewport);
  //   } else {
  //     map.setCenter(_place.geometry.location);
  //     map.setZoom(16);  // 16 cos jersey number
  //   }

  //   marker.setPosition(_place.geometry.location);
  //   map.setCenter(_place.geometry.location);

  //   setLocationData(_place.name, _place);
  //   openInfoWindow(marker);
  // });

  // google.maps.event.addListener(map, 'click', function (e) {
  //   infoWindow.close();
  //   setMarker(e.latLng);
  //   showLocation(e.latLng);
  // });

  // function setMarker(latLng) {
  //   marker.setPosition(latLng);
  // }

  // function showLocation(latLng) {
  //   geocodeLocation(latLng, function (result) {
  //     if (result) {
  //       setLocationData(result['formatted_address'], result)
  //       openInfoWindow(marker);
  //     }
  //   });
  // };

  // function geocodeLocation(latLng, callback) {
  //   geocoder.geocode({ location: latLng }, function (results, status) {
  //     if (status === "OK") {
  //       callback(results[0]);
  //     } else {
  //       alert("Unable to get location detail: " + status + "\nPlease try again");
  //       callback();
  //     }
  //   });
  // };

  // function formAddress(components) {
  //   return _.chain(components)
  //           .filter(function (component) { return component['types'][0] !== 'locality' })
  //           .pluck('long_name')
  //           .value()
  //           .join(' ');
  // }

  // function openInfoWindow(marker) {
  //   var _marker = marker,
  //       content = '<div><strong>' + LOCATION['name'] + '</strong><br>' + LOCATION['address'] + '</div>';
  //   infoWindow.setContent(content);
  //   infoWindow.open(map, _marker);
  // };

  // function setLocationData(name, place) {
  //   LOCATION = {
  //     name: name,
  //     address: formAddress(place['address_components']),
  //     latitude: place.geometry.location.lat().toFixed(7),
  //     longitude: place.geometry.location.lng().toFixed(7)
  //   }
  // };
}
