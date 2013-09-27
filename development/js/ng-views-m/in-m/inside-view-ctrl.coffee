app.controller 'InsideViewCtrl',
['$scope', 'MpProjects', 'MpChatbox', '$location', 'MpUser',
( $scope,   MpProjects,   MpChatbox,   $location,   MpUser) ->

  @MpProjects = new MpProjects()
  @MpChatbox  = MpChatbox

  MpChatbox.connect()

  @createNewProject = ->
    @MpProjects.createProject().then (project) ->
      $location.path('/mobile/project/' + project.id)
    $scope.interface.showUserSection = false

  @showDashboard = ->
    $location.path('/mobile/dashboard')
    $scope.interface.showUserSection = false

  @logout = ->
    MpUser.logout()
    $scope.interface.showUserSection = false

  return
]
