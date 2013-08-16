# AllProjectsCtrl
app.controller 'AllProjectsViewCtrl',
['$rootScope', '$scope', '$location', '$window',
($rootScope, $scope, $location, $window) ->

  $scope.userLocation = $window.userLocation

  $scope.showEditProjectModal = (project) ->
    $rootScope.$broadcast 'showBottomModalbox', {type: 'editProject', project: project}

  $scope.openProjectView = (project) ->
    $location.path '/project/' + project.id
]
