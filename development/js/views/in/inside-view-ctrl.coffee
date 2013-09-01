app.controller 'InsideViewCtrl',
['$scope', 'MpProjects', 'MpChatbox', '$location',
( $scope,   MpProjects,   MpChatbox,   $location) ->

  @MpProjects = new MpProjects()
  @MpChatbox  = MpChatbox

  MpChatbox.connect()

  @createNewProject = ->
    @MpProjects.createProject().then (project) ->
      $location.path('/project/' + project.id)

  return
]
