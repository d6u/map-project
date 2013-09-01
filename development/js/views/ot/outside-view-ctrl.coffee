app.controller 'OutsideViewCtrl',
['$scope', 'MpChatbox', 'MpUser',
( $scope,   MpChatbox,   MpUser) ->

  MpChatbox.destroy()

  @hideHomepage = false

  @loginWithFacebook = ->
    MpUser.login '/dashboard', ->
      $scope.interface.showUserSection = false

  return
]
