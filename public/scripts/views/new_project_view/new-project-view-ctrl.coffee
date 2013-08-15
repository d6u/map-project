app.controller 'NewProjectViewCtrl',
['$scope', '$location',
($scope, $location) ->

  # events
  $scope.$on 'projectUpdated', ->
    # $location.path('/project/' + MpProjects.project.id)

  $scope.$on 'projectRemoved', (event, project_id) ->
    $location.path('/all_projects')
]
