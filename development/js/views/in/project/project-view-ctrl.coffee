app.controller 'ProjectViewCtrl',
['$scope', ($scope) ->

  # FIXME: auto detect current template
  $scope.outsideViewCtrl = {hideHomepage: true}

  return
]
