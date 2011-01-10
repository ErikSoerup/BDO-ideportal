ideax = {
  map: {
    newMap: function(divId, lat, lon, zoom) {
      return new google.maps.Map(
        document.getElementById(divId),
        {
          zoom: zoom,
          center: new google.maps.LatLng(lat, lon),
          mapTypeId: google.maps.MapTypeId.ROADMAP
        }
      )
    },

    addIdea: function(map, ideaLat, ideaLon, ideaTitle, popupContent) {
      var ideaLoc = new google.maps.LatLng(ideaLat, ideaLon)
      var marker = new google.maps.Marker({
          position:   ideaLoc,
          map:        map, 
          icon:       ideax.map.markerIcon,
          shadow:     ideax.map.markerShadow,
          animation:  google.maps.Animation.DROP,
          title:      ideaTitle
      })
      
      google.maps.event.addListener(marker, 'click', function() {
        if(map.openInfoWindow)
          map.openInfoWindow.close()
        
        var infoWindow = new google.maps.InfoWindow({
          content: popupContent
        })
        infoWindow.open(map, marker)
        map.openInfoWindow = infoWindow
      })
    },
    
    markerIcon: new google.maps.MarkerImage(
      '/images/idea-marker.png',
      new google.maps.Size(14,19), // size
      new google.maps.Point(0,0),  // origin
      new google.maps.Point(7,16)  // anchor
    ),
    
    markerShadow: new google.maps.MarkerImage(
      '/images/idea-shadow.png',
      new google.maps.Size(30, 19), // size
      new google.maps.Point(0,0),   // origin
      new google.maps.Point(7,16)   // anchor
    ),
    
    // showGeolocatedMap: function() {
    //   // Adapted from http://code.google.com/apis/maps/documentation/javascript/basics.html#DetectingUserLocation
    //   var userLocation = null
    //   if(navigator.geolocation) {
    //     // W3C Geolocation (Preferred)
    //     navigator.geolocation.getCurrentPosition(function(position) {
    //       searchIdeasNear(position.coords.latitude, position.coords.longitude)
    //     }, function() {
    //       searchIdeasNearDefault()
    //     })
    //   } else if (google.gears) {
    //     // Google Gears Geolocation
    //     var geo = google.gears.factory.create('beta.geolocation')
    //     geo.getCurrentPosition(function(position) {
    //       searchIdeasNear(position.latitude,position.longitude)
    //     }, function() {
    //       searchIdeasNearDefault()
    //     })
    //   } else {
    //     // Browser doesn't support Geolocation
    //     searchIdeasNearDefault()
    //   }
    // }
  }
}
