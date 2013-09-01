app.controller 'OutsideViewCtrl',
['$scope', 'MpUser', ($scope, MpUser) ->

  @hideHomepage = false

  @loginWithFacebook = ->
    MpUser.login '/dashboard', ->
      $scope.interface.showUserSection = false

  return
]
