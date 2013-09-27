app.controller 'ProjectViewCtrl',
['$scope', class ProjectViewCtrl

  constructor: ($scope) ->
    # drawer
    @showDrawer    = false
    @activeSection = 'searchResults'

    # FIXME: auto detect current template
    $scope.outsideViewCtrl = {hideHomepage: true}
]
