app = angular.module 'angular-mp.home.all-projects-view', []


# AllProjectsCtrl
app.controller 'AllProjectsViewCtrl',
['$rootScope', '$scope', 'MpProjects', '$location', 'User', '$window','TheMap',
'$route',
($rootScope, $scope, MpProjects, $location, User, $window, TheMap, $route) ->

  if !User.checkLogin() then return

  $scope.userLocation = $window.userLocation

  $scope.showEditProjectModal = (project) ->
    $rootScope.$broadcast 'showBottomModalbox', {type: 'editProject', project: project}

  $scope.openProjectView = (project) ->
    $location.path '/project/' + project.id

  # init
  console.log 'AllProjectsCtrl'
]


# mp-all-projects-item
app.directive 'mpAllProjectsItem', [->
  (scope, element, attrs) ->

    if scope.project.owner_id != scope.User.$$user.id
      scope.projectMessage = 'This is a group project'
]


# mini-map-cover
app.directive 'miniMapCover', [ ->
  scope: true
  link: (scope, element, attrs) ->

    mapOptions =
      center: new google.maps.LatLng(scope.userLocation.latitude, scope.userLocation.longitude)
      zoom: 12
      mapTypeId: google.maps.MapTypeId.ROADMAP
      disableDefaultUI: true
      disableDoubleClickZoom: true
      draggable: false
      scrollwheel: false

    scope.miniMap = new google.maps.Map(element[0], mapOptions)

    if scope.project.places_attrs.places_coords.length > 0
      bounds = new google.maps.LatLngBounds()

      for coord in scope.project.places_attrs.places_coords
        coordMatch = /\((.+), (.+)\)/.exec coord
        latLog = new google.maps.LatLng coordMatch[1], coordMatch[2]
        markerOptions =
          map: scope.miniMap
          position: latLog
          cursor: 'default'
        marker = new google.maps.Marker markerOptions
        bounds.extend marker.getPosition()

      scope.miniMap.fitBounds bounds
]
