#= require libraries/lodash.js
#= require libraries/socket.io.min.js
#= require libraries/jquery-ui-1.10.3.custom.min.js
#= require libraries/jquery.easyModal.js
#= require libraries/masonry.pkgd.min.js
#= require libraries/bootstrap.min.js
#= require libraries/perfect-scrollbar-0.4.3.min.js
#= require libraries/perfect-scrollbar-0.4.3.with-mousewheel.min.js
#= require libraries/angular.min.js
#= require libraries/restangular.js
#= require modules_for_libraries/angular-easy-modal.coffee
#= require modules_for_libraries/angular-facebook.coffee
#= require modules_for_libraries/angular-socket.io.coffee
#= require modules_for_libraries/angular-masonry.coffee
#= require modules_for_libraries/angular-perfect-scrollbar.coffee
#= require modules_for_libraries/angular-bootstrap.coffee
#= require modules_for_libraries/angular-jquery-ui.coffee
#= require mp_modules/angular-mp.home.initializer.coffee
#= require mp_modules/angular-mp.api.coffee
#= require mp_modules/angular-mp.home.shared.coffee
#= require mp_modules/angular-mp.home.outside-view.coffee
#= require mp_modules/angular-mp.home.all-projects-view.coffee
#= require mp_modules/angular-mp.home.new-project-view.coffee
#= require mp_modules/angular-mp.home.project-view.coffee
#= require mp_modules/angular-mp.home.helpers.coffee



# declear
app = angular.module 'mapApp', [
  'restangular',

  'angular-easy-modal',
  'angular-facebook',
  'angular-socket.io',
  'angular-masonry',
  'angular-perfect-scrollbar',
  'angular-bootstrap',
  'angular-jquery-ui',

  'angular-mp.home.initializer',
  'angular-mp.api',
  'angular-mp.home.shared',
  'angular-mp.home.outside-view',
  'angular-mp.home.all-projects-view',
  'angular-mp.home.new-project-view',
  'angular-mp.home.project-view',

  'angular-mp.home.helpers'
]


# config
app.config([
  'FBProvider', 'socketProvider', '$httpProvider', '$routeProvider',
  '$locationProvider',
  (FBProvider, socketProvider, $httpProvider, $routeProvider,
   $locationProvider) ->

    # route
    $routeProvider
    .when('/', {
      controller: 'OutsideViewCtrl'
      templateUrl: 'outside_view'
      resolve:
        FB: 'FB'
    })
    .when('/all_projects', {
      controller: 'AllProjectsViewCtrl'
      templateUrl: 'all_projects_view'
      resolve:
        FB: 'FB'
    })
    .when('/new_project', {
      controller: 'NewProjectViewCtrl'
      templateUrl: 'new_project_view'
      resolve:
        FB: 'FB'
    })
    .when('/project/:project_id', {
      controller: 'ProjectViewCtrl'
      templateUrl: 'project_view'
      resolve:
        FB: 'FB'
        socket: 'socket'
        Chatbox: 'Chatbox'
    })
    .otherwise({redirectTo: '/'})

    $locationProvider.html5Mode true

    # CSRF
    token = angular.element('meta[name="csrf-token"]').attr('content')
    $httpProvider.defaults.headers.common['X-CSRF-Token'] = token

    # google map
    google.maps.visualRefresh = true

    # socket
    socketProvider.setServerUrl location.protocol + '//' + location.hostname + ':4000'
])


# run
app.run(['$rootScope', '$location', 'FB',
  ($rootScope, $location, FB) ->

    $rootScope.googleMap =
      markers: []
      infoWindow: new google.maps.InfoWindow()
      # map, searchBox

    $rootScope.currentProject =
      project: {}
      places: []

    $rootScope.interface =
      showChatbox: false
      showPlacesList: false
      sideBarPlacesSlideUp: true
      showCreateAccountPromot: false

    # callbacks
    loginSuccess = ->
      if $rootScope.currentProject.places.length > 0
        $location.path('/new_project')
      else
        $location.path('/all_projects')

    logoutSuccess = ->
      $location.path('/')

    # resolver
    FB.then (FB) ->
      # filter
      if $rootScope.user.fb_access_token
        $location.path('/all_projects') if $location.path() == '/'
      else
        $location.path('/') if $location.path() != '/'

      # global methods
      $rootScope.fbLogin = -> FB.doLogin loginSuccess, logoutSuccess
      $rootScope.fbLogout = -> FB.doLogout logoutSuccess
])


# MapCtrl
# ========================================
app.controller 'MapCtrl',
['$scope', '$timeout', '$q', '$templateCache', '$compile', '$rootScope',
($scope, $timeout, $q, $templateCache, $compile, $rootScope)->

  # interface
  $scope.inMapview = true

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
      bounds.extend newPlace.$$marker.getPosition()
      bindInfoWindow newPlace

    $scope.googleMap.map.fitBounds bounds
    $scope.googleMap.map.setZoom(12) if places.length < 3 && $scope.googleMap.map.getZoom() > 12
    $timeout (-> google.maps.event.trigger $scope.googleMap.markers[0], 'click'), 800 if places.length == 1

  cleanMarkers = ->
    marker.setMap(null) for marker in $scope.googleMap.markers
    $scope.googleMap.markers = []

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

  $scope.centerPlaceInMap = (marker) ->
    marker.getMap().setCenter marker.getPosition()

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
