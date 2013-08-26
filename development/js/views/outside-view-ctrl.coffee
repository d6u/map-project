app.controller 'OutsideViewCtrl',
['$scope', 'MpProjects', 'TheMap', 'TheProject', 'MpChatbox',
( $scope,   MpProjects,   TheMap,   TheProject,   MpChatbox) ->

  MpChatbox.destroy()
]
