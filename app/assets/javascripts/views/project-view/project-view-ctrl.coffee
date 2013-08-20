app.controller 'ProjectViewCtrl',
['$scope', '$location', '$routeParams', 'TheProject', 'Restangular', 'TheMap',
( $scope,   $location,   $routeParams,   TheProject,   Restangular,   TheMap) ->

  $scope.TheMap = TheMap

  if $scope.MpProjects.TheProject
    $scope.TheProject = $scope.MpProjects.TheProject
    delete $scope.MpProjects.TheProject
    $scope.MpProjects.findProjectById($routeParams.project_id).then (project) ->
      $scope.TheProject.project  = project
      $scope.TheProject.$$places = Restangular.one('projects', project.id).all('places')
      _places = $scope.TheProject.places
      $scope.TheProject.places = []
      _places.forEach (place) ->
        $scope.TheProject.addPlace(place)
  else
    $scope.TheProject = new TheProject($routeParams.project_id)


  @addPlaceToList = (place) ->
    $scope.TheMap.searchResults = _.without $scope.TheMap.searchResults, place
    $scope.TheProject.addPlace(place)
]
