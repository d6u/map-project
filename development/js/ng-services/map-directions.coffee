app.factory 'MapDirections',
['$q','MapPlaces','TheMap',
( $q,  MapPlaces,  TheMap) ->

  class MapDirections

    ROUTE_REQUEST_DEFAULTS: {
      avoidHighways:            false
      avoidTolls:               false
      durationInTraffic:        false
      optimizeWaypoints:        false
      provideRouteAlternatives: false
      travelMode: google.maps.TravelMode.DRIVING
      unitSystem: google.maps.UnitSystem.IMPERIAL
    }

    constructor: () ->
      @$autoRender = false

      @$directionService   = new google.maps.DirectionsService
      @$directionsRenderer = new google.maps.DirectionsRenderer({
        draggable:     false
        hideRouteList: true
        polylineOptions:
          clickable:     false
          draggable:     false
          editable:      false
          geodesic:      true
          strokeColor:   '#967ADC'
          strokeOpacity: 1
          strokeWeight:  5
        preserveViewport: true
        suppressMarkers:  true
      })


      MapPlaces.on 'all', (eventName) =>
        if @$autoRender
          if MapPlaces.length >= 2
            if eventName in ['add', 'remove', 'sort', 'sync']
              @route().then =>
                @renderDirections()
          else
            if eventName == 'remove'
              @$directionsRenderer.setMap(null)



    # if didn't provide request object, will use data in MapPlaces service
    # should at least provide
    #   origin, waypoints, destination
    route: (request) ->
      _arguments    = arguments
      gotDirections = $q.defer()

      if request?
        request = _.merge({}, @ROUTE_REQUEST_DEFAULTS, request)
      else
        if MapPlaces.length < 2
          gotDirections.reject()
          return gotDirections.promise

        waypoints = [] if MapPlaces.length > 2

        for place, i in MapPlaces.models
          if 0 < i < MapPlaces.length - 1
            waypoints.push({location: place.getPosition(), stopover: true})
          else if i == 0
            destination = place.getPosition()
          else
            origin = place.getPosition()

        request = _.merge({}, @ROUTE_REQUEST_DEFAULTS, {
          destination: destination
          origin:      origin
          waypoints:   waypoints
        })

      @$directionService.route request, (response, status) =>
        # INVALID_REQUEST
        # MAX_WAYPOINTS_EXCEEDED
        # NOT_FOUND
        # OK
        # OVER_QUERY_LIMIT
        # REQUEST_DENIED
        # UNKNOWN_ERROR
        # ZERO_RESULTS - no results
        if status == google.maps.DirectionsStatus.OK
          @$lastResults = response

          # assign direction information to saved places
          if !_arguments[0]?
            for leg, idx in response.routes[0].legs
              MapPlaces.at(idx).set({direction_leg: leg})
            MapPlaces.at(MapPlaces.length - 1).unset('direction_leg')

          gotDirections.resolve(response)
        else
          console.debug 'MapDirections error: ', status
          gotDirections.reject()

      return gotDirections.promise


    # use last results to render directions
    renderDirections: ->
      if !@$directionsRenderer.getMap()?
        @$directionsRenderer.setMap(TheMap.getMap())
      @$directionsRenderer.setDirections(@$lastResults)


    toggleAutoRender: ->
      @$autoRender = !@$autoRender
      if @$autoRender
        @$directionsRenderer.setMap(TheMap.getMap())
        if MapPlaces.length >= 2
          @route().then =>
            @renderDirections()
      else
        @$directionsRenderer.setMap(null)
        place.unset('direction_leg') for place in MapPlaces.models

  # --- END MapDirections ---


  return new MapDirections
]
