app.controller 'OutsideViewCtrl',
['$scope', 'MpUser', ($scope, MpUser) ->

  @hideHomepage      = false
  @workplaceScrollup = false
  @showChat          = false

  @loginWithFacebook = ->
    MpUser.login '/mobile/dashboard', ->
      $scope.interface.showUserSection = false

  return
]
