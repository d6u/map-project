app.controller 'InsideViewCtrl',
['$scope', 'MpProjects', 'MpChatbox',
( $scope,   MpProjects,   MpChatbox) ->

  @MpProjects = MpProjects
  @MpChatbox  = MpChatbox

  MpProjects.getProjects()
  MpChatbox.connect()

  return
]
