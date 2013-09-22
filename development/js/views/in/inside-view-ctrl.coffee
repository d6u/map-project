app.controller 'InsideViewCtrl',
['$scope','MpProjects','MpNotification','$location','MpFriends','socket','MpUser',
( $scope,  MpProjects,  MpNotification,  $location,  MpFriends,  socket,  MpUser) ->

  @MpProjects     = MpProjects
  @MpNotification = MpNotification
  @MpFriends      = MpFriends
  @MpUser         = MpUser

  MpProjects.initialize     $scope
  MpFriends.initialize      $scope
  MpNotification.initialize $scope

  socket.connect()

  # --- View's methods ---
  @createNewProject = ->
    @MpProjects.createProject().then (project) ->
      $location.path('/project/' + project.id)

  @logout = ->
    socket.disconnect()
    MpUser.logout ->
      $location.path '/'

  @showInvitationDialog = false


  # --- Return ---
  return
]
