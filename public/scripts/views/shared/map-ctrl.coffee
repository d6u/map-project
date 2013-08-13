# MapCtrl
# ========================================
app.controller 'MapCtrl',
['$scope', 'TheMap', '$timeout', '$q', '$templateCache', '$compile',
'$rootScope', 'MpProjects',
($scope, TheMap, $timeout, $q, $templateCache, $compile, $rootScope,
 MpProjects) ->

  # TODO: rename
  $rootScope.googleMap = TheMap
  $rootScope.currentProject = MpProjects

  # New API
  $rootScope.TheMap = TheMap
  $rootScope.MpProjects = MpProjects

  # callbacks
  # triggerMapResize = ->
  #   $timeout (->
  #     google.maps.event.trigger(TheMap.map, 'resize')
  #   ), 200

  # actions
  $scope.addPlaceToList = (place) ->
    TheMap.markers = _.filter TheMap.markers, (marker) ->
      return true if marker.__gm_id != place.$$marker.__gm_id
    place.$$marker.setMap null
    delete place.$$marker
    place.id = true
    place.order = MpProjects.currentProject.places.length
    MpProjects.currentProject.places.push place

  $scope.centerPlaceInMap = (location) ->
    TheMap.map.setCenter location

  $scope.removePlace = (place, index) ->
    MpProjects.currentProject.places.splice(index, 1)[0]
    place.$$marker.setMap null

  $scope.displayAllMarkers = ->
    bounds = new google.maps.LatLngBounds()
    for place in MpProjects.currentProject.places
      bounds.extend place.$$marker.getPosition()
    TheMap.map.fitBounds bounds
    TheMap.map.setZoom 12 if MpProjects.currentProject.places.length < 3 && TheMap.map.getZoom() > 12

  # $scope.deleteAllSavedPlaces = ->
  #   if confirm('Are you sure to delete all saved places? This action is irreversible.')
  #     place.$$marker.setMap null for place in ActiveProject.places
  #     ActiveProject.places = []
  #     $rootScope.$broadcast 'allPlacesRemovedFromList'

  # events
  TheMap.mapReady = $q.defer()
  TheMap.searchBoxReady = $q.defer()

  $q.all([TheMap.mapReady.promise, TheMap.searchBoxReady.promise]).then ->

    google.maps.event.addListener(TheMap.map, 'bounds_changed',
      -> TheMap.searchBox.setBounds TheMap.map.getBounds())

    google.maps.event.addListener(TheMap.searchBox, 'places_changed', ->
      $scope.$apply -> TheMap.searchResults = TheMap.searchBox.getPlaces())

  $scope.$on 'mpInputboxClearInput', -> TheMap.searchResults = []
]
