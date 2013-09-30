app.factory 'TheMap',
['MpLocation','$q',
( MpLocation,  $q) ->

  class TheMap
    constructor: ->
      @$infoWindow           = new google.maps.InfoWindow()
      @$autocompleteService  = new google.maps.places.AutocompleteService()
      @$placesService        = undefined # placeholder
      @$directionsService    = new google.maps.DirectionsService()
      @$directionsRenderer   = new google.maps.DirectionsRenderer({
        # options
        polylineOptions:
          strokeColor: '977ADC'
          strokeOpacity: 1
          strokeWeight: 5
        suppressMarkers: true
        suppressInfoWindows: true
      })

      # properties
      @$markers = []

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

      @destroy = ->

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

      # return promise
      #   resolve: predictions
      #   reject: google service status
      @getSearchPredictions = (input) ->
        gotPredictions = $q.defer()
        @$autocompleteService.getQueryPredictions {
          bounds: @$googleMap.getBounds()
          input:  input
        }, (predictions, status) ->
          if status == google.maps.DirectionsStatus.OK
            gotPredictions.resolve(predictions)
          else
            gotPredictions.reject(status)
        gotPredictions.promise

      # return promise
      #   resolve: search results
      #   reject: google service status
      @searchPlacesWith = (query) ->
        gotResults = $q.defer()
        @$placesService ?= new google.maps.places.PlacesService(@$googleMap)
        @$placesService.textSearch {
          bounds: @$googleMap.getBounds()
          query:  query
        }, (results, status) ->
          if status == google.maps.DirectionsStatus.OK
            gotResults.resolve(results)
          else
            gotResults.reject(status)
        gotResults.promise

      @setMapCenter = (latLng) ->
        @$googleMap.setCenter(latLng)

      @setMapBounds = (bounds) ->
        @$googleMap.fitBounds(bounds)


  # --- END ---
  return new TheMap
]
