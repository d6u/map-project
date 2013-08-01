#= require libraries/modernizr.min.js
#= require libraries/google.map.infobox.js
#= require libraries/socket.io.min.js
#= require libraries/jquery.js
#= require modules/perfect-scrollbar-0.4.3.min.js
#= require modules/perfect-scrollbar-0.4.3.with-mousewheel.min.js
#= require libraries/angular.min.js
#= require modules/angular-socket.io.coffee
#= require modules/angular-resource.min.js
#= require modules/angular-tp.resources.coffee
#= require modules/angular-mp.home.index.directives.coffee



# declear
app = angular.module('mapApp',
  ['angular-socket.io', 'angular-tp.resources', 'angular-mp.home.index.directives'])

# config
app.config([
  'socketProvider', '$httpProvider', '$routeProvider',
  (socketProvider, $httpProvider, $routeProvider) ->
    # CSRF
    token = angular.element('meta[name="csrf-token"]').attr('content')
    $httpProvider.defaults.headers.common['X-CSRF-Token'] = token

    # socket
    socketProvider.setServerUrl('http://local.dev:4000')

    # route
    $routeProvider
    .when('/')
    .when('/all_projects', {
      controller: 'AllProjectsCtrl'
      templateUrl: 'all_projects_view'
    })
    .when('/new_project', {
      controller: 'ProjectCtrl'
      templateUrl: 'project_view'
    })
    .when('/project/:project_id', {
      controller: 'ProjectCtrl'
      templateUrl: 'project_view'
    })
    .otherwise({redirectTo: '/'})

])

app.run([
  '$rootScope', '$route', '$location', '$http',
  ($rootScope, $route, $location, $http) ->
    # TODO: redirect according to user's projects
    if $location.path() == '/'
      $location.path('/new_project')

    # get user location according to ip
    $rootScope.userLocation = $http.jsonp('http://www.geoplugin.net/json.gp?jsoncallback=JSON_CALLBACK')
    .then (response) ->
      return {
        latitude: response.data.geoplugin_latitude
        longitude: response.data.geoplugin_longitude
      }

    # google map object
    $rootScope.googleMap =
      markers: []

    # interface control
    $rootScope.interface =
      hideChatbox: true
      hidePlacesList: true
      sideBarPlacesSlideUp: true
      showCreateAccountPromot: false
])


app.controller('AllProjectsCtrl',
['$scope',
($scope) ->

])

app.controller('ProjectCtrl',
['$scope',
($scope) ->
  rearrangeMarkerIcons = ->
    place.marker.setIcon({url: "/assets/number_#{index}.png"}) for place, index in $scope.places

  $scope.places = []

  $scope.addPlaceToList = (place) ->
    if $scope.interface.hidePlacesList
      $scope.interface.hidePlacesList = false
      $scope.interface.sideBarPlacesSlideUp = false
    place.marker.setMap(null)
    place.marker = new google.maps.Marker({
      map: $scope.googleMap.map
      title: place.name
      position: place.place.geometry.location
      icon:
        url: "/assets/number_#{$scope.places.length}.png"
    })
    $scope.places.push place
    if $scope.places.length > 1
      $scope.interface.showCreateAccountPromot = true

  $scope.centerPlaceInMap = (marker) ->
    marker.getMap().setCenter marker.getPosition()

  $scope.removePlace = (index, marker) ->
    marker.setMap(null)
    $scope.places.splice(index, 1)
    rearrangeMarkerIcons()
])
