app.controller 'InsideViewCtrl',
['$scope', 'MpProjects', 'MpChatbox',
( $scope,   MpProjects,   MpChatbox) ->

  $scope.MpProjects = MpProjects
  $scope.MpChatbox  = MpChatbox

  $scope.loadProjects = MpProjects.getProjects()
  MpChatbox.connect()
]
