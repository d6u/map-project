app.controller 'ProjectViewCtrl',
['$scope', '$routeSegment', 'ChatHistories', 'ParticipatingUsers',
class ProjectViewCtrl

  constructor: ($scope, $routeSegment, ChatHistories, ParticipatingUsers) ->

    # --- Init Services ---
    childScope = $scope.$new()

    ParticipatingUsers.initProject(
      $routeSegment.$routeParams.project_id,
      childScope)

    ChatHistories.initProject(
      $routeSegment.$routeParams.project_id,
      childScope)





    # drawer
    @showDrawer    = false

    # FIXME: auto detect current template
    $scope.outsideViewCtrl = {hideHomepage: true}
]
