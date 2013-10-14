app.controller 'InsideViewCtrl',
['$scope','MpProjects','MpNotification','$location','MpFriends','socket',
 'MpUser','MpInvitation', class InsideViewCtrl

  constructor: ($scope, MpProjects, MpNotification, $location, MpFriends, socket, MpUser, MpInvitation) ->

    # --- Init Services ---
    childScope = $scope.$new()

    MpProjects.initService(childScope)
    MpFriends.initService(childScope)


    # --- Listeners ---
    MpProjects.on 'all', =>
      @projects = MpProjects.models

    MpFriends.on 'all', =>
      @friends = MpFriends.models


    # old
    MpNotification.initialize $scope
    socket.connect()
    @MpNotification = MpNotification
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
