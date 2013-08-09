app = angular.module 'angular-mp.home.map', []


# map service
# ========================================
app.factory 'TheMap', [->

  return {
    map: null
    infoWindow: new google.maps.InfoWindow()
    searchBox: null
    markers: []
    searchResults: []
    reset: ->
      @markers = []
      @searchResults = []
  }
]


# MapCtrl
# ========================================
app.controller 'MapCtrl',
['$scope', 'TheMap', '$timeout', '$q', '$templateCache', '$compile',
'$rootScope', 'ActiveProject',
($scope, TheMap, $timeout, $q, $templateCache, $compile, $rootScope,
 ActiveProject) ->

  # TODO: rename
  $rootScope.googleMap = TheMap
  $rootScope.currentProject = ActiveProject

  # New API
  $rootScope.TheMap = TheMap
  $rootScope.ActiveProject = ActiveProject

  # callbacks
  triggerMapResize = ->
    $timeout (->
      google.maps.event.trigger(TheMap.map, 'resize')
    ), 200

  searchBoxPlaceChanged = ->
    cleanMarkers()
    bounds = new google.maps.LatLngBounds()
    places = TheMap.searchBox.getPlaces()
    animation = if places.length == 1 then google.maps.Animation.DROP else null

    for place in places
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
      TheMap.searchResults.push place
      bounds.extend newPlace.$$marker.getPosition()
      bindInfoWindow newPlace

    $scope.$apply()
    TheMap.map.fitBounds bounds
    TheMap.map.setZoom(12) if places.length < 3 && TheMap.map.getZoom() > 12
    $timeout (-> google.maps.event.trigger TheMap.markers[0], 'click'), 800

  cleanMarkers = ->
    marker.setMap(null) for marker in TheMap.markers
    TheMap.markers = []
    TheMap.searchResults = []

  bindInfoWindow = (place) ->
    google.maps.event.addListener place.$$marker, 'click', ->
      infoWindow = TheMap.infoWindow
      template = $templateCache.get 'marker_info_window'
      newScope = $scope.$new()
      newScope.place = place
      compiled = $compile(template)(newScope)
      TheMap.infoWindow.setContent compiled[0]
      google.maps.event.clearListeners infoWindow, 'closeclick'
      google.maps.event.addListenerOnce infoWindow, 'closeclick', ->
        newScope.$destroy()
      infoWindow.open TheMap.map, place.$$marker

  rearrangePlacesList = ->
    for place, index in ActiveProject.places
      # update marker icon
      place.$$marker.setIcon {url: "/assets/number_#{index}.png"}
      # update order
      place.order = index
    $rootScope.$broadcast 'undatedPlacesOrders'

  # actions
  $scope.addPlaceToList = (place) ->
    place.$$marker.setMap null
    markerOptions =
      map: TheMap.map
      title: place.name
      position: place.$$marker.getPosition()
      icon:
        url: "/assets/number_#{ActiveProject.places.length}.png"
    place.$$marker = new google.maps.Marker markerOptions
    place.id = true
    place.order = ActiveProject.places.length

    ActiveProject.places.push place
    $rootScope.$broadcast 'placeAddedToList', place

  $scope.centerPlaceInMap = (location) ->
    TheMap.map.setCenter location
    # marker.getMap().setCenter marker.getPosition()

  $scope.removePlace = (place, index) ->
    ActiveProject.places.splice(index, 1)[0]
    place.$$marker.setMap null
    rearrangePlacesList()
    $rootScope.$broadcast 'placeRemovedFromList', place

  $scope.displayAllMarkers = ->
    bounds = new google.maps.LatLngBounds()
    for place in ActiveProject.places
      bounds.extend place.$$marker.getPosition()
    TheMap.map.fitBounds bounds
    TheMap.map.setZoom 12 if ActiveProject.places.length < 3 && TheMap.map.getZoom() > 12

  $scope.deleteAllSavedPlaces = ->
    if confirm('Are you sure to delete all saved places? This action is irreversible.')
      place.$$marker.setMap null for place in ActiveProject.places
      ActiveProject.places = []
      $rootScope.$broadcast 'allPlacesRemovedFromList'

  $scope.clearSearchResults = ->
    cleanMarkers()

  # events
  TheMap.mapReady = $q.defer()
  TheMap.searchBoxReady = $q.defer()

  $q.all([TheMap.mapReady.promise, TheMap.searchBoxReady.promise]).then ->

    google.maps.event.addListener(TheMap.map, 'bounds_changed',
      -> TheMap.searchBox.setBounds TheMap.map.getBounds())

    google.maps.event.addListener(TheMap.searchBox, 'places_changed', searchBoxPlaceChanged)

  $scope.$on 'placeListSorted', rearrangePlacesList
  $scope.$on 'mpInputboxClearInput', cleanMarkers
]


# Map Components
# ----------------------------------------
# google-map
app.directive 'googleMap', ['$window', 'TheMap', ($window, TheMap) ->
  (scope, element, attrs) ->

    mapOptions =
      center: new google.maps.LatLng($window.userLocation.latitude, $window.userLocation.longitude)
      zoom: 8
      mapTypeId: google.maps.MapTypeId.ROADMAP
      disableDefaultUI: true

    TheMap.map = new google.maps.Map(element[0], mapOptions)
    TheMap.mapReady.resolve()
]


# inforwindow
app.directive 'markerInfo', [-> (scope, element, attrs) -> scope.$apply()]


# List Components
# ----------------------------------------
# mp-places-list
app.directive 'mpPlacesList', ['$window', '$rootScope',
($window, $rootScope) ->

  templateUrl: 'mp_places_list_template'
  link: (scope, element, attrs) ->

    hideListAccordingly = ->
      listEmpty = scope.ActiveProject.places.length == 0 && scope.TheMap.searchResults.length == 0
      if listEmpty
        element.addClass 'hide'
      else
        element.removeClass 'hide'

    scope.$watch 'ActiveProject.places.length', (newVal, oldVal, scope) ->
      hideListAccordingly()

    scope.$watch 'TheMap.searchResults.length', (newVal, oldVal, scope) ->
      hideListAccordingly()

    scope.showEditProjectModal = (project) ->
      $rootScope.$broadcast 'showBottomModalbox', {type: 'editProject', project: project}







    $($window).on 'resize', ->
      element.css {maxHeight: $($window).height() - 112 - 20}
    $($window).trigger 'resize'

    element.perfectScrollbar({
      wheelSpeed: 20
      wheelPropagation: true
      })

    scope.$watch 'currentProject.places.length', (newVal, oldVal) ->
      # TODO: scroll to places list last (newest) item
      element.scrollTop 0
      element.perfectScrollbar 'update'

    scope.$watch 'googleMap.searchResults.length', (newVal, oldVal) ->
      # TODO: scroll to search result position
      element.scrollTop 0
      element.perfectScrollbar 'update'
]



# sidebar place
app.directive 'sidebarPlace', ['$templateCache', '$compile',
($templateCache, $compile) ->
  (scope, element, attrs) ->

    google.maps.event.addListener scope.place.$$marker, 'click', ->
      template = $templateCache.get('marker_info_window')
      compiled = $compile(template)(scope)
      scope.googleMap.infoWindow.setContent(compiled[0])
      scope.googleMap.infoWindow.open(scope.place.$$marker.getMap(), scope.place.$$marker)
]
