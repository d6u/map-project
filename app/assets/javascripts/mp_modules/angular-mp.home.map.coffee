app = angular.module 'angular-mp.home.map', []


# MapCtrl
# ========================================
app.controller 'MapCtrl',
['$scope', '$timeout', '$q', '$templateCache', '$compile', '$rootScope',
($scope, $timeout, $q, $templateCache, $compile, $rootScope)->

  # callbacks
  triggerMapResize = ->
    $timeout (->
      google.maps.event.trigger($scope.googleMap.map, 'resize')
    ), 200

  searchBoxPlaceChanged = ->
    cleanMarkers()
    bounds = new google.maps.LatLngBounds()
    places = $scope.googleMap.searchBox.getPlaces()
    animation = if places.length == 1 then google.maps.Animation.DROP else null

    for place in places
      markerOptions =
        map: $scope.googleMap.map
        title: place.name
        position: place.geometry.location
        animation: animation
      newPlace =
        $$marker: new google.maps.Marker markerOptions
        notes: null
        name: place.name
        address: place.formatted_address
        coord: place.geometry.location.toString()

      $scope.googleMap.markers.push newPlace.$$marker
      $scope.googleMap.searchResults.push place
      bounds.extend newPlace.$$marker.getPosition()
      bindInfoWindow newPlace

    $scope.$apply()
    $scope.googleMap.map.fitBounds bounds
    $scope.googleMap.map.setZoom(12) if places.length < 3 && $scope.googleMap.map.getZoom() > 12
    $timeout (-> google.maps.event.trigger $scope.googleMap.markers[0], 'click'), 800 if places.length == 1

  cleanMarkers = ->
    marker.setMap(null) for marker in $scope.googleMap.markers
    $scope.googleMap.markers = []
    $scope.googleMap.searchResults = []

  bindInfoWindow = (place) ->
    google.maps.event.addListener place.$$marker, 'click', ->
      infoWindow = $scope.googleMap.infoWindow
      template = $templateCache.get 'marker_info_window'
      newScope = $scope.$new()
      newScope.place = place
      compiled = $compile(template)(newScope)
      $scope.googleMap.infoWindow.setContent compiled[0]
      google.maps.event.clearListeners infoWindow, 'closeclick'
      google.maps.event.addListenerOnce infoWindow, 'closeclick', ->
        newScope.$destroy()
      infoWindow.open $scope.googleMap.map, place.$$marker

  rearrangePlacesList = ->
    for place, index in $scope.currentProject.places
      # update marker icon
      place.$$marker.setIcon {url: "/assets/number_#{index}.png"}
      # update order
      place.order = index
    $rootScope.$broadcast 'undatedPlacesOrders'

  # actions
  $scope.addPlaceToList = (place) ->
    place.$$marker.setMap null
    markerOptions =
      map: $scope.googleMap.map
      title: place.name
      position: place.$$marker.getPosition()
      icon:
        url: "/assets/number_#{$scope.currentProject.places.length}.png"
    place.$$marker = new google.maps.Marker markerOptions
    place.id = true
    place.order = $scope.currentProject.places.length

    $scope.currentProject.places.push place
    $rootScope.$broadcast 'placeAddedToList', place

  $scope.centerPlaceInMap = (location) ->
    $scope.googleMap.map.setCenter location
    # marker.getMap().setCenter marker.getPosition()

  $scope.removePlace = (place, index) ->
    $scope.currentProject.places.splice(index, 1)[0]
    place.$$marker.setMap null
    rearrangePlacesList()
    $rootScope.$broadcast 'placeRemovedFromList', place

  $scope.displayAllMarkers = ->
    bounds = new google.maps.LatLngBounds()
    for place in $scope.currentProject.places
      bounds.extend place.$$marker.getPosition()
    $scope.googleMap.map.fitBounds bounds
    $scope.googleMap.map.setZoom 12 if $scope.currentProject.places.length < 3 && $scope.googleMap.map.getZoom() > 12

  $scope.deleteAllSavedPlaces = ->
    if confirm('Are you sure to delete all saved places? This action is irreversible.')
      place.$$marker.setMap null for place in $scope.currentProject.places
      $scope.currentProject.places = []
      $rootScope.$broadcast 'allPlacesRemovedFromList'

  # events
  $scope.googleMap.mapReady = $q.defer()
  $scope.googleMap.searchBoxReady = $q.defer()
  $q.all([$scope.googleMap.mapReady.promise, $scope.googleMap.searchBoxReady.promise])
  .then ->
    $scope.$watch('interface.showPlacesList', triggerMapResize)
    $scope.$watch('interface.showChatbox', triggerMapResize)
    google.maps.event.addListener($scope.googleMap.map, 'bounds_changed',
      -> $scope.googleMap.searchBox.setBounds $scope.googleMap.map.getBounds())

    google.maps.event.addListener($scope.googleMap.searchBox, 'places_changed', searchBoxPlaceChanged)

  $scope.$on 'placeListSorted', rearrangePlacesList
]

