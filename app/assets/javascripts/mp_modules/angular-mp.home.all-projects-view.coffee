app = angular.module 'angular-mp.home.all-projects-view', []


# AllProjectsCtrl
app.controller 'AllProjectsViewCtrl',
['$rootScope', '$scope', 'Project', '$location', 'User', '$window', 'ActiveProject',
($rootScope, $scope, Project, $location, User, $window, ActiveProject) ->

  $scope.showEditProjectModal = (project) ->
    $rootScope.$broadcast 'showBottomModalbox', {type: 'editProject', project: project}

  # init
  Project.getList().then (projects) ->
    if projects.length > 0
      $scope.projects = projects
    else
      $scope.projects = []
      $location.path('/new_project')

  $scope.userLocation = $window.userLocation

  ActiveProject.reset()

  # events
  $scope.$on 'projectRemoved', (event, project_id) ->
    index = _.findIndex $scope.projects, {id: project_id}
    project = $scope.projects.splice(index, 1)[0]
    project.remove()
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
