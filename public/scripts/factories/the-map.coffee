# map service
# ========================================
app.factory 'TheMap', ['$rootScope', 'MpProjects', '$timeout',
'mpTemplateCache', '$compile',
($rootScope, MpProjects, $timeout, mpTemplateCache, $compile) ->

  # callbacks
  # ----------------------------------------
  bindInfoWindow = (place) ->
    google.maps.event.addListener place.$$marker, 'click', ->
      mpTemplateCache.get('scripts/views/shared/marker-info.html').then (template) ->
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
    markers: []
    searchResults: []
    __searchResults: []

    reset: ->
      @markers = []
      @searchResults = []
      @__searchResults = []

    addPlaceToList: (place) ->
      # remove selected marker from this.markers
      @markers = _.filter @markers, (marker) ->
        return true if marker.__gm_id != place.$$marker.__gm_id

      place.$$marker.setMap null
      delete place.$$marker
      place.id = true
      place.order = MpProjects.currentProject.places.length
      MpProjects.currentProject.places.push place

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
  # TheMap.searchResults
  $rootScope.$watch(
    (->
      return _.pluck TheMap.searchResults, 'id'
    ),
    ((newVal, oldVal) ->
      marker.setMap(null) for marker in TheMap.markers
      TheMap.markers = []
      return if newVal.length == 0

      # entered new searchResults
      places = TheMap.searchResults
      bounds = new google.maps.LatLngBounds()
      animation = if places.length == 1 then google.maps.Animation.DROP else null
      _.forEach places, (place) ->
        markerOptions =
          map: TheMap.map
          title: place.name
          position: place.geometry.location
          animation: animation
        newPlace =
          $$marker: new google.maps.Marker markerOptions
          notes: null
          name: place.name
          address: place.formatted_address
          coord: place.geometry.location.toString()
        TheMap.markers.push newPlace.$$marker
        place.mpObject = newPlace
        bounds.extend newPlace.$$marker.getPosition()
        bindInfoWindow newPlace

      TheMap.map.fitBounds bounds
      TheMap.map.setZoom(12) if places.length < 3 && TheMap.map.getZoom() > 12
      $timeout (-> google.maps.event.trigger TheMap.markers[0], 'click'), 800
    ), true
  )

  # watch for marked places and make marker for them
  $rootScope.$watch(
    (->
      return if $rootScope.User && $rootScope.User.checkLogin() then {attr: 'id', content: _.pluck(MpProjects.currentProject.places, 'id')} else {attr: 'order', content: _.pluck(MpProjects.currentProject.places, 'order')}
    ),
    ((newVal, oldVal) ->
      _.forEach  MpProjects.currentProject.places, (place, idx) ->
        if place.$$marker
          place.$$marker.setMap null
          delete place.$$marker
        coordMatch = /\((.+), (.+)\)/.exec place.coord
        latLog = new google.maps.LatLng coordMatch[1], coordMatch[2]
        markerOptions =
          map: TheMap.map
          title: place.name
          position: latLog
          icon:
            url: "/assets/number_#{idx}.png"
        place.$$marker = new google.maps.Marker markerOptions
    ), true
  )

  # TODO: remove if only one place use it
  $rootScope.$on 'mpInputboxClearInput', -> TheMap.searchResults = []


  # return
  return TheMap
]
