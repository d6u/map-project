# map service
# ========================================
app.factory 'TheMap',
['$rootScope', 'MpProjects', '$timeout', 'mpTemplateCache', '$compile',
( $rootScope,   MpProjects,   $timeout,   mpTemplateCache,   $compile) ->

  # service
  # ----------------------------------------
  TheMap =
    # Map related service
    infoWindow:         new google.maps.InfoWindow()
    directionsService:  new google.maps.DirectionsService()
    directionsRenderer: new google.maps.DirectionsRenderer({
      polylineOptions:
        strokeColor: '977ADC'
        strokeOpacity: 1
        strokeWeight: 5
      suppressMarkers: true
      suppressInfoWindows: true
    })

    $$currentScope: null
    map: null
    searchBox: null
    # need to be reset
    searchResults:   []
    __searchResults: []

    reset: ->
      @searchResults   = []
      @__searchResults = []

    centerPlaceInMap: (location) ->
      @map.setCenter location

    displayAllMarkers: ->
      bounds = new google.maps.LatLngBounds()
      for place in MpProjects.currentProject.places
        bounds.extend place.$$marker.getPosition()
      @map.fitBounds bounds
      @map.setZoom 12 if MpProjects.currentProject.places.length < 3 && @map.getZoom() > 12

    # bind callback to TheMap, make it accessable outside of TheMap factory
    bindInfoWindow: (place, scope) ->
      google.maps.event.addListener place.$$marker, 'click', ->
        mpTemplateCache.get('/scripts/views/_map/marker-info.html').then (template) ->
          newScope = scope.$new()
          newScope.place = place
          compiled = $compile(template)(newScope)
          TheMap.infoWindow.setContent compiled[0]
          google.maps.event.clearListeners TheMap.infoWindow, 'closeclick'
          google.maps.event.addListenerOnce TheMap.infoWindow, 'closeclick', ->
            newScope.$destroy()
          TheMap.infoWindow.open TheMap.map, place.$$marker


  # return
  # ----------------------------------------
  return TheMap
]
