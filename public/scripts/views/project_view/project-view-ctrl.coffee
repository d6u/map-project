app.controller 'ProjectViewCtrl',
['$scope', '$location', ($scope, $location) ->

  # events
  $scope.$on 'projectRemoved', (event) ->
    $location.path('/all_projects')
]
