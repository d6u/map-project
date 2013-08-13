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
