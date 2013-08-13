app.controller 'NewProjectViewCtrl',
['$scope', '$location', '$rootScope', '$q', '$timeout', '$templateCache',
'$compile', 'User', 'TheMap', 'MpProjects',
($scope, $location, $rootScope, $q, $timeout, $templateCache,
 $compile, User, TheMap, MpProjects) ->

  if !User.checkLogin() then return

  # events
  $scope.$on 'projectUpdated', ->
    # $location.path('/project/' + MpProjects.project.id)

  $scope.$on 'projectRemoved', (event, project_id) ->
    $location.path('/all_projects')
]
