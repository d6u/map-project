app.controller 'OutsideViewCtrl',
['$scope', 'MpProjects', 'TheMap', 'TheProject', 'MpChatbox',
( $scope,   MpProjects,   TheMap,   TheProject,   MpChatbox) ->

  @hideHomepage      = false
  @workplaceScrollup = false
  @showChat          = false

  MpChatbox.destroy()

  return
]
