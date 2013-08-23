app.controller 'OutsideViewCtrl',
['$scope', 'MpProjects', 'TheMap', 'TheProject',
( $scope,   MpProjects,   TheMap,   TheProject) ->

  $scope.TheProject = new TheProject()
  $scope.TheMap = TheMap

  @addPlaceToList = (place) ->
    $scope.TheMap.searchResults = _.without $scope.TheMap.searchResults, place
    $scope.TheProject.addPlace(place)
]
