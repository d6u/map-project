app.controller 'InsideViewCtrl',
['$scope', 'MpProjects', 'MpChatbox', '$location',
( $scope,   MpProjects,   MpChatbox,   $location) ->

  @MpProjects = MpProjects
  @MpChatbox  = MpChatbox

  MpProjects.getProjects()
  MpChatbox.connect()

  @createNewProject = ->
    MpProjects.createProject().then (project) ->
      $location.path('/project/' + project.id)

  return
]
