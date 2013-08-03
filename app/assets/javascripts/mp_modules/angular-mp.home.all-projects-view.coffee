app = angular.module 'angular-mp.home.all-projects-view', []


# AllProjectsCtrl
app.controller 'AllProjectsViewCtrl', ['$scope', 'Project', '$location',
($scope, Project, $location) ->

  $scope.projects = []

  Project.query (projects) ->
    if projects.length > 0
      $scope.projects = projects
    else
      $location.path('/new_project')
]
