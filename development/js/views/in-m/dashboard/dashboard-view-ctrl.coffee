app.controller 'DashboardViewCtrl',
['$rootScope', '$scope', '$location', '$window',
( $rootScope,   $scope,   $location,   $window) ->

  # used in mini map to center map if no places in project
  # TODO: add location error handling
  $scope.userLocation = $window.userLocation

  return
]
