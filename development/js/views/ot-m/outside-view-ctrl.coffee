app.controller 'OutsideViewCtrl',
['$scope', 'MpProjects', 'TheMap', 'TheProject', 'MpChatbox',
( $scope,   MpProjects,   TheMap,   TheProject,   MpChatbox) ->

  @hideHomepage      = true
  @workplaceScrollup = false

  MpChatbox.destroy()

  return
]
