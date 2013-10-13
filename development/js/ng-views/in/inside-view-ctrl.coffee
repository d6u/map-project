app.controller 'InsideViewCtrl',
['$scope','MpProjects','MpNotification','$location','MpFriends','socket',
 'MpUser','MpInvitation', class InsideViewCtrl

  constructor: ($scope, MpProjects, MpNotification, $location, MpFriends, socket, MpUser, MpInvitation) ->

    # --- Init Services ---
    childScope = $scope.$new()

    MpProjects.initService(childScope)


    # --- Listeners ---
    MpProjects.on 'all', =>
      @projects = MpProjects.models


    MpFriends.initialize      $scope
    MpNotification.initialize $scope

    socket.connect()

    @MpNotification = MpNotification
    @MpFriends      = MpFriends
    @MpUser         = MpUser


    # --- UI Actions ---
    @createNewProject = ->
      MpProjects.create({}, {
        success: (project) ->
          $location.path("/project/#{project.id}")
      })

    @logout = ->
      socket.disconnect()
      MpUser.logout ->
        $location.path '/'

    @showInvitationDialog = false
]
