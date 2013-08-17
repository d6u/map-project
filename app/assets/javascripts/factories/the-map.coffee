# map service
# ========================================
app.factory 'TheMap', ['$rootScope', 'MpProjects', '$timeout',
'mpTemplateCache', '$compile',
($rootScope, MpProjects, $timeout, mpTemplateCache, $compile) ->

  # callbacks
  # ----------------------------------------
  bindInfoWindow = (place) ->
    google.maps.event.addListener place.$$marker, 'click', ->
      mpTemplateCache.get('/scripts/views/shared/marker-info.html').then (template) ->
        newScope = $rootScope.$new()
        newScope.place = place
        compiled = $compile(template)(newScope)
        TheMap.infoWindow.setContent compiled[0]
        google.maps.event.clearListeners TheMap.infoWindow, 'closeclick'
        google.maps.event.addListenerOnce TheMap.infoWindow, 'closeclick', ->
          newScope.$destroy()
        TheMap.infoWindow.open TheMap.map, place.$$marker


  # service
  # ----------------------------------------
  TheMap =
    map: null
    infoWindow: new google.maps.InfoWindow()
    searchBox: null
    # need to be reset
    markers:         []
    searchResults:   []
    __searchResults: []

    reset: ->
      @markers         = []
      @searchResults   = []
      @__searchResults = []

    addPlaceToList: (place) ->
      # remove selected marker from TheMap.markers
      return if !place.$$marker
      @markers = _.filter @markers, (marker) ->
        return true if marker.__gm_id != place.$$marker.__gm_id

      place.$$marker.setMap null
      delete place.$$marker
      _place = _.clone(place)
      _place.order = MpProjects.currentProjectPlaces.length
      MpProjects.currentProjectPlaces.push _place

    centerPlaceInMap: (location) ->
      @map.setCenter location

    displayAllMarkers: ->
      bounds = new google.maps.LatLngBounds()
      for place in MpProjects.currentProject.places
        bounds.extend place.$$marker.getPosition()
      @map.fitBounds bounds
      @map.setZoom 12 if MpProjects.currentProject.places.length < 3 && @map.getZoom() > 12


  # watcher
  # ----------------------------------------
  # TheMap.searchResults, add marker for each result
  $rootScope.$watch(
    (->
      return _.pluck TheMap.searchResults, 'id'
    ),
    ((newVal, oldVal) ->
      marker.setMap(null) for marker in TheMap.markers
      TheMap.markers = []
      return if newVal.length == 0

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
        TheMap.markers.push place.$$marker
        bounds.extend place.$$marker.getPosition()
        bindInfoWindow place

      TheMap.map.fitBounds bounds
      TheMap.map.setZoom(12) if places.length < 3 && TheMap.map.getZoom() > 12
      $timeout (-> google.maps.event.trigger TheMap.markers[0], 'click'), 800
    ), true
  )

  # watch for marked places and make marker for them
  $rootScope.$watch(
    (->
      return _.pluck(MpProjects.currentProjectPlaces, 'id')
    ),
    ((newVal, oldVal) ->
      _.forEach MpProjects.currentProjectPlaces, (place, idx) ->
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
            url: "/img/markers/number_#{idx}.png"
        place.$$marker = new google.maps.Marker markerOptions
        bindInfoWindow place
    ), true
  )


  # return
  # ----------------------------------------
  return TheMap
]
