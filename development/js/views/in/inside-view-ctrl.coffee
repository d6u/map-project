app.controller 'InsideViewCtrl',
['$scope','MpProjects','MpNotification','$location','MpFriends',
( $scope,  MpProjects,  MpNotification,  $location,  MpFriends) ->

  @MpProjects     = new MpProjects()
  @MpNotification = MpNotification
  @mpFriends      = new MpFriends()

  MpNotification.connect()

  @createNewProject = ->
    @MpProjects.createProject().then (project) ->
      $location.path('/project/' + project.id)

  return
]
