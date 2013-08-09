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
    __searchResults: []
    reset: ->
      @markers = []
      @searchResults = []
      @__searchResults = []
  }
]


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
    place.$$marker.setIcon {
      url: "/assets/number_#{MpProjects.currentProject.places.length}.png"
    }
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
    for place in ActiveProject.places
      bounds.extend place.$$marker.getPosition()
    TheMap.map.fitBounds bounds
    TheMap.map.setZoom 12 if ActiveProject.places.length < 3 && TheMap.map.getZoom() > 12

  $scope.deleteAllSavedPlaces = ->
    if confirm('Are you sure to delete all saved places? This action is irreversible.')
      place.$$marker.setMap null for place in ActiveProject.places
      ActiveProject.places = []
      $rootScope.$broadcast 'allPlacesRemovedFromList'

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


# Map Components
# ----------------------------------------
# google-map
app.directive 'googleMap', ['$window', 'TheMap', '$templateCache', '$compile',
'$timeout', 'MpProjects',
($window, TheMap, $templateCache, $compile, $timeout, MpProjects) ->
  (scope, element, attrs) ->

    mapOptions =
      center: new google.maps.LatLng($window.userLocation.latitude, $window.userLocation.longitude)
      zoom: 8
      mapTypeId: google.maps.MapTypeId.ROADMAP
      disableDefaultUI: true

    TheMap.map = new google.maps.Map(element[0], mapOptions)

    bindInfoWindow = (place) ->
      google.maps.event.addListener place.$$marker, 'click', ->
        infoWindow = TheMap.infoWindow
        template = $templateCache.get 'marker_info_window'
        newScope = scope.$new()
        newScope.place = place
        compiled = $compile(template)(newScope)
        TheMap.infoWindow.setContent compiled[0]
        google.maps.event.clearListeners infoWindow, 'closeclick'
        google.maps.event.addListenerOnce infoWindow, 'closeclick', ->
          newScope.$destroy()
        infoWindow.open TheMap.map, place.$$marker

    # watch TheMap.searchResults
    scope.$watch ((currentScope) ->
      if TheMap.searchResults.length == TheMap.__searchResults.length && TheMap.searchResults[0] == TheMap.__searchResults[0]
        return false
      else if TheMap.searchResults.length == 0
        return null
      else
        TheMap.__searchResults = _.clone(TheMap.searchResults)
        return TheMap.searchResults
    ), ((newVal, oldVal, currentScope) ->
      if newVal == false then return

      marker.setMap(null) for marker in TheMap.markers
      TheMap.markers = []
      if newVal == null then return

      # entered new searchResults
      places = newVal
      bounds = new google.maps.LatLngBounds()
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
        bounds.extend newPlace.$$marker.getPosition()
        bindInfoWindow newPlace

      TheMap.map.fitBounds bounds
      TheMap.map.setZoom(12) if places.length < 3 && TheMap.map.getZoom() > 12
      $timeout (-> google.maps.event.trigger TheMap.markers[0], 'click'), 800
    )

    # mapReady
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
      listEmpty = scope.MpProjects.currentProject.places.length == 0 && scope.TheMap.searchResults.length == 0
      if listEmpty then element.addClass 'hide' else element.removeClass 'hide'

    scope.$watch 'MpProjects.currentProject.places.length', (newVal, oldVal, scope) ->
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

    scope.$watch 'MpProjects.currentProject.places.length', (newVal, oldVal) ->
      # TODO: scroll to places list last (newest) item
      element.scrollTop 0
      element.perfectScrollbar 'update'

    scope.$watch 'TheMap.searchResults.length', (newVal, oldVal) ->
      # TODO: scroll to search result position
      # TODO: not only update according to length
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
