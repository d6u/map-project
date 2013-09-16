app.controller 'InsideViewCtrl',
['$scope','MpProjects','MpNotification','$location','MpFriends','socket',
( $scope,  MpProjects,  MpNotification,  $location,  MpFriends,  socket) ->

  @MpProjects     = MpProjects
  @MpNotification = MpNotification
  @MpFriends      = MpFriends

  MpProjects.initialize     $scope
  MpFriends.initialize      $scope
  MpNotification.initialize $scope

  socket.connect()

  # --- View's methods ---
  @createNewProject = ->
    @MpProjects.createProject().then (project) ->
      $location.path('/project/' + project.id)


  # --- Return ---
  return
]
