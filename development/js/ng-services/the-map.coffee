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
      @setMapCenter = (latLng) ->
        @$googleMap.setCenter(latLng)

      @setMapBounds = (bounds) ->
        @$googleMap.fitBounds(bounds)

      @getMap = ->
        @$googleMap

      @getBounds = ->
        @getMap()?.getBounds()

  # --- END TheMap class ---


  # extending EventEmitter onto TheMap without changing CoffeeScript syntax
  _.assign TheMap.prototype, EventEmitter.prototype


  # --- END ---
  return new TheMap
]
