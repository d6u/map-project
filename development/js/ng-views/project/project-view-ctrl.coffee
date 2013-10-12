app.controller 'ProjectViewCtrl',
['$scope','$routeSegment','ChatHistories','ParticipatingUsers','MapPlaces',
class ProjectViewCtrl

  constructor: ($scope, $routeSegment, ChatHistories, ParticipatingUsers,
  MapPlaces) ->

    # --- Init Services ---
    childScope = $scope.$new()

    MapPlaces.initProject(
      $routeSegment.$routeParams.project_id,
      childScope)

    ParticipatingUsers.initProject(
      $routeSegment.$routeParams.project_id,
      childScope)

    ChatHistories.initProject(
      $routeSegment.$routeParams.project_id,
      childScope)
]
