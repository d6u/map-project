app = angular.module 'angular-mp.home.outside-view', []


app.controller 'OutsideViewCtrl',['$scope',
($scope) ->

  $scope.currentProject.project = {}
  $scope.currentProject.places = []
]
