app.controller 'ProjectViewCtrl',
['$scope', ($scope) ->

  @showChatbox = false

  # FIXME: auto detect current template
  $scope.outsideViewCtrl = {hideHomepage: true}

  return
]
