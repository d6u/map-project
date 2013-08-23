# map service
# ========================================
app.factory 'TheMap',
['$rootScope', 'MpProjects', '$timeout', 'mpTemplateCache', '$compile',
( $rootScope,   MpProjects,   $timeout,   mpTemplateCache,   $compile) ->

  # service
  # ----------------------------------------
  TheMap =
    $$currentScope: null
    map: null
    infoWindow: new google.maps.InfoWindow()
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
        mpTemplateCache.get('/scripts/views/shared/marker-info.html').then (template) ->
          newScope = scope.$new()
          newScope.place = place
          compiled = $compile(template)(newScope)
          TheMap.infoWindow.setContent compiled[0]
          google.maps.event.clearListeners TheMap.infoWindow, 'closeclick'
          google.maps.event.addListenerOnce TheMap.infoWindow, 'closeclick', ->
            newScope.$destroy()
          TheMap.infoWindow.open TheMap.map, place.$$marker


  # watcher
  # ----------------------------------------
  # TheMap.searchResults, add marker for each result
  $rootScope.$watch(
    (->
      return _.pluck TheMap.searchResults, 'id'
    ),
    ((newVal, oldVal) ->
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
        TheMap.bindInfoWindow place, TheMap.$$currentScope

      TheMap.__searchResults = _.clone TheMap.searchResults
      TheMap.map.fitBounds bounds
      TheMap.map.setZoom(12) if places.length < 3 && TheMap.map.getZoom() > 12
      $timeout (-> google.maps.event.trigger TheMap.searchResults[0].$$marker, 'click'), 800
    ), true
  )


  # return
  # ----------------------------------------
  return TheMap
]
