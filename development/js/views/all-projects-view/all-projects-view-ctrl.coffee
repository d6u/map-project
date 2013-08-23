# AllProjectsCtrl
app.controller 'AllProjectsViewCtrl',
['$rootScope', '$scope', '$location', '$window',
( $rootScope,   $scope,   $location,   $window) ->

  # used in mini map to center map if no places in project
  $scope.userLocation = $window.userLocation

  this.createNewProject = ->
    $scope.MpProjects.createProject().then (project) ->
      $location.path('/home/project/'+project.id)
]
