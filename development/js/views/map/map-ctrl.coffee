app.controller 'MapCtrl',
['$scope', 'TheProject', 'TheMap',
( $scope,   TheProject,   TheMap) ->

  # TODO: bind to mapCtrl
  @theProject       = new TheProject()
  $scope.TheProject = @theProject
  $scope.TheMap     = TheMap


  @addPlaceToList = (place) ->
    $scope.TheMap.searchResults = _.without $scope.TheMap.searchResults, place
    $scope.TheProject.addPlace(place)


  ###
  Toggle directions between places
  Google API Doc https://developers.google.com/maps/documentation/javascript/directions#DirectionsRequests

  Request object
  {
    origin (required): LatLng | String,
    destination (required): LatLng | String,
    travelMode (required): TravelMode,
      # google.maps.TravelMode.DRIVING
      # google.maps.TravelMode.BICYCLING
      # google.maps.TravelMode.TRANSIT
      # google.maps.TravelMode.WALKING
    transitOptions: TransitOptions,
      # Options for TRANSIT travel mode
    unitSystem: UnitSystem,
    durationInTraffic: Boolean,
    waypoints[]: DirectionsWaypoint,
      # location
      # stopover (bool)
    optimizeWaypoints: Boolean,
    provideRouteAlternatives: Boolean,
    avoidHighways: Boolean,
    avoidTolls: Boolean
    region: String
  }
  ###
  @toggleDirections = ->
    places = @theProject.places
    return if places.length < 2
    requestObj = {
      travelMode: google.maps.TravelMode.DRIVING
      waypoints:  []
    }
    for place, idx in places
      if idx > 0 && idx < (places.length - 1)
        waypointObj = {
          location: place.$$marker.getPosition()
          stopover: true
        }
        requestObj.waypoints.push(waypointObj)
      else if idx == 0
        requestObj.origin = place.$$marker.getPosition()
      else
        requestObj.destination = place.$$marker.getPosition()
    # Send request
    TheMap.directionsService.route requestObj, (result, status) ->
      if status == google.maps.DirectionsStatus.OK
        ###
        Renderer options
        https://developers.google.com/maps/documentation/javascript/reference#DirectionsRendererOptions
        {
          directions:             DirectionsResult
          draggable:              bool
          hideRouteList:          bool
          infoWindow:             InfoWindow
          map:                    Map
          markerOptions:          MarkerOptions
          panel:                  DOM Node
          polylineOptions:        PolylineOptions
          preserveViewport:       bool (false)
          routeIndex:             number
          suppressBicyclingLayer: bool
          suppressInfoWindows:    bool
          suppressMarkers:        bool
          suppressPolylines:      bool
        }

        PolylineOptions
        https://developers.google.com/maps/documentation/javascript/reference#PolylineOptions
        {
          clickable:     bool
          draggable:     bool
          editable:      bool
          geodesic:      bool
          icons:         Array <IconSequence>
          map:           Map
          path:          coordinates Array
          strokeColor:   string <CSS Color>
          strokeOpacity: number
          strokeWeight:  number
          visible:       bool
          zIndex:        number
        }
        ###
        TheMap.directionsRenderer.setMap(TheMap.map) if !TheMap.directionsRenderer.getMap()
        console.debug result
        TheMap.directionsRenderer.setDirections(result)
]
