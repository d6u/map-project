app.factory 'TheMap',
['MpLocation','$q','$compile',
( MpLocation,  $q,  $compile) ->

  class TheMap
    constructor: ->
      @$directionsService  = new google.maps.DirectionsService
      @$directionsRenderer = new google.maps.DirectionsRenderer({
        # options
        polylineOptions:
          strokeColor: '977ADC'
          strokeOpacity: 1
          strokeWeight: 5
        suppressMarkers: true
        suppressInfoWindows: true
      })

      # properties
      @$markers     = []
      @$infoWindows = []

      @initialize = (mapDiv, options={}, scope) ->
        location    = MpLocation.getLocation()
        @$googleMap = new google.maps.Map mapDiv, _.assign({
          # default options
          center: new google.maps.LatLng(location.latitude, location.longitude)
          zoom: 8
          mapTypeId: google.maps.MapTypeId.ROADMAP
          disableDefaultUI: true
        }, options)

        scope.$on '$destroy', =>
          @destroy()

        @trigger 'initialized'

      @destroy = ->
        delete @$googleMap
        @trigger 'destroyed'

      # --- API ---
      @addMarkersOnMap = (markers, fitBounds) ->
        markers = [markers] if !markers.length?
        for marker in markers
          marker.setMap(@$googleMap)
          @$markers.push marker
        if fitBounds
          bounds = new google.maps.LatLngBounds
          bounds.extend marker.getPosition() for marker in markers
          @setMapBounds bounds

      @clearMarkers = (markers) ->
        markers = [markers] if !markers.length?
        marker.setMap null for marker in markers
        @$markers = _.difference(@$markers, markers)

      @clearAllMarkers = ->
        marker.setMap(null) for marker in @$markers
        @$markers = []

      @setMapCenter = (latLng) ->
        @$googleMap.setCenter(latLng)

      @setMapBounds = (bounds) ->
        @$googleMap.fitBounds(bounds)

      @getMap = ->
        @$googleMap

      @bindInfoWindowToMarker = (marker, contentTemplate, scope, options={}) ->
        infoWindow = new google.maps.InfoWindow _.assign({
          maxWidth: 320
          content:  $compile(contentTemplate)(scope)[0]
        }, options)
        @$infoWindows.push infoWindow

        google.maps.event.addListener marker, 'click', =>
          _infoWindow.close() for _infoWindow in @$infoWindows
          infoWindow.open @getMap(), marker

        return infoWindow

      @removeInfoWindows = (infoWindows) ->
        infoWindows = [infoWindows] if !infoWindows.length?
        infoWindow.close() for infoWindow in infoWindows
        @$infoWindows = _.difference(@$infoWindows, infoWindows)


  # --- END TheMap class ---


  # extending EventEmitter onto TheMap without changing CoffeeScript syntax
  _.assign TheMap.prototype, EventEmitter.prototype


  # --- END ---
  return new TheMap
]
