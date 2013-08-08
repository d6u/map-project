app = angular.module 'angular-mp.home.outside-view', []


app.controller 'OutsideViewCtrl',['$rootScope', '$scope', 'User',
($rootScope, $scope, User) ->

  $scope.currentProject.project = {}
  $scope.currentProject.places = []
]
