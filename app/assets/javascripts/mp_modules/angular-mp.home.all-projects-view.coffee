app = angular.module 'angular-mp.home.all-projects-view', []


# AllProjectsCtrl
app.controller 'AllProjectsViewCtrl',
['$scope', 'Project', '$location', 'userLocation',
($scope, Project, $location, userLocation) ->

  # init
  if $scope.user.fb_access_token
    Project.getList().then (projects) ->
      if projects.length > 0
        $scope.projects = projects
      else
        $scope.projects = []
        $location.path('/new_project')

  $scope.userLocation = userLocation

  # TODO
  $scope.currentProject.projects = {}
  $scope.currentProject.places = []
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
