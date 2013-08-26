app.controller 'MapCtrl',
['$scope', 'TheProject', 'TheMap',
( $scope,   TheProject,   TheMap) ->

  # TODO: bind to mapCtrl
  @theProject       = new TheProject()
  theProject        = @theProject
  $scope.TheProject = @theProject
  $scope.TheMap     = TheMap


  # Callback functions
  # ----------------------------------------
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
  renderDirections = ->
    clearDirections()
    places = $scope.mapCtrl.theProject.places
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
    TheMap.directionsService.route requestObj, (result, status) =>
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
        TheMap.directionsRenderer.setDirections(result)
        # Map the route leg data to places object, so it can be displayed in places list and infoWindow
        $scope.$apply =>
          for leg, idx in result.routes[0].legs
            $scope.mapCtrl.theProject.places[idx].$$leg = leg


  clearDirections = ->
    for place in $scope.mapCtrl.theProject.places
      delete place.$$leg
    TheMap.directionsRenderer.setMap(null) if TheMap.directionsRenderer.getMap()


  @addPlaceToList = (place) ->
    $scope.TheMap.searchResults = _.without $scope.TheMap.searchResults, place
    $scope.TheProject.addPlace(place)

  @showDirections = false

  @toggleDirections = ->
    @showDirections = !@showDirections
    if @showDirections
      renderDirections()
    else
      clearDirections()


  # Watch places list changes
  # ----------------------------------------
  # TheMap.searchResults, add marker for each result
  $scope.$watch (->
    return _.pluck TheMap.searchResults, 'id'
  ), ((newVal, oldVal) ->
    TheMap.__searchResults.forEach (place) ->
      place.$$marker.setMap null
    if newVal.length == 0
      TheMap.__searchResults = _.clone TheMap.searchResults
      return
      # --- END ---

    # new searchResults entered
    places = TheMap.searchResults
    bounds = new google.maps.LatLngBounds()
    animation = if places.length == 1 then google.maps.Animation.DROP else null
    _.forEach places, (place) ->
      markerOptions =
        map:       TheMap.map
        title:     place.name
        position:  place.geometry.location
        animation: animation
      place.$$marker = new google.maps.Marker markerOptions
      place.notes    = null
      place.address  = place.formatted_address
      place.coord    = place.geometry.location.toString()
      bounds.extend place.$$marker.getPosition()
      TheMap.bindInfoWindow(place, $scope)

    TheMap.__searchResults = _.clone TheMap.searchResults
    TheMap.map.fitBounds bounds
    TheMap.map.setZoom(11) if places.length < 3
  ), true


  # watch for marked places and make marker for them
  $scope.$watch (=>
    return _.pluck(@theProject.places, 'id')
  ), ((newVal, oldVal) =>
    if newVal
      # re-render marker for each places
      _.forEach @theProject.places, (place, idx) ->
        # $$saved is used to hide infoWindow add place button
        place.$$saved = true
        if place.$$marker
          place.$$marker.setMap null
          delete place.$$marker
        if place.geometry
          latLog = place.geometry.location
        else
          coordMatch = /\((.+), (.+)\)/.exec place.coord
          latLog = new google.maps.LatLng coordMatch[1], coordMatch[2]
        markerOptions =
          map: TheMap.map
          title: place.name
          position: latLog
          icon:
            url: "/img/blue-marker-3d.png"
        place.$$marker = new google.maps.Marker markerOptions
        TheMap.bindInfoWindow(place, $scope)

      # re-render directions if showDirections == true
      if @showDirections
        renderDirections()
  ), true


  # Return
  return
]
