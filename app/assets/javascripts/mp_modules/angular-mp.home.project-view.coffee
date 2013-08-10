app = angular.module 'angular-mp.home.project-view', []


app.controller 'ProjectViewCtrl',
['$scope', 'MpProjects', 'TheMap', '$location', '$route', '$rootScope',
'$routeParams', 'User',
($scope, MpProjects, TheMap, $location, $route, $rootScope, $routeParams,
 User) ->

  if !User.checkLogin() then return

  # events
  $scope.$on 'projectRemoved', (event) ->
    $location.path('/all_projects')
]
