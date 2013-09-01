app.controller 'OutsideViewCtrl',
['$scope', 'MpChatbox', 'MpUser',
( $scope,   MpChatbox,   MpUser) ->

  MpChatbox.destroy()

  @hideHomepage = false

  @loginWithFacebook = ->
    MpUser.login('/mobile/dashboard')
    $scope.interface.showUserSection = false

  return
]
