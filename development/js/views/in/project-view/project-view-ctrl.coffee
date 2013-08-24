app.controller 'ProjectViewCtrl',
['$scope', '$location', '$routeParams', 'TheProject', 'Restangular', 'TheMap',
( $scope,   $location,   $routeParams,   TheProject,   Restangular,   TheMap) ->

  $scope.TheMap     = TheMap

  $scope.loadProjects.then ->
    $scope.TheProject = new TheProject(Number($routeParams.project_id))

  @addPlaceToList = (place) ->
    $scope.TheMap.searchResults = _.without $scope.TheMap.searchResults, place
    $scope.TheProject.addPlace(place)
]
