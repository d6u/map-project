app.controller 'InsideViewCtrl',
['$scope','MpProjects','MpChatbox','$location','MpFriends',
( $scope,  MpProjects,  MpChatbox,  $location,  MpFriends) ->

  @MpProjects = new MpProjects()
  @MpChatbox  = MpChatbox
  @mpFriends  = new MpFriends()

  MpChatbox.connect()

  @createNewProject = ->
    @MpProjects.createProject().then (project) ->
      $location.path('/project/' + project.id)

  return
]
