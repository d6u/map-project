app = angular.module 'angular-mp.home.all-projects-view', []


# AllProjectsCtrl
app.controller 'AllProjectsViewCtrl',
['$rootScope', '$scope', 'MpProjects', '$location', 'User', '$window','TheMap',
($rootScope, $scope, MpProjects, $location, User, $window, TheMap) ->

  $scope.showEditProjectModal = (project) ->
    $rootScope.$broadcast 'showBottomModalbox', {type: 'editProject', project: project}

  $scope.userLocation = $window.userLocation

  # init
  MpProjects.getProjects({include_participated: true}).then ->
    if MpProjects.projects.length == 0
      $location.path('/new_project')
    else
      MpProjects.clean()
      TheMap.reset()

  # events
  $scope.$on 'projectRemoved', (event, project_id) ->
    index = _.findIndex $scope.projects, {id: project_id}
    project = $scope.projects.splice(index, 1)[0]
    project.remove()
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
