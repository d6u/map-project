app.controller 'OutsideViewCtrl',
['$scope', 'MpUser', class OutsideViewCtrl

  constructor: ($scope, MpUser) ->
    @hideHomepage = false
    @loginWithFacebook = ->
      MpUser.login '/dashboard', ->
        $scope.interface.showUserSection = false
]
