app.controller 'InsideViewCtrl',
['$scope','MpProjects','MpNotification','$location','MpFriends','socket',
 'MpUser', class InsideViewCtrl

  constructor: ($scope, MpProjects, MpNotification, $location, MpFriends, socket, MpUser) ->

    # --- Init Services ---
    socket.connect()

    childScope = $scope.$new()

    MpProjects.initService     childScope
    MpFriends.initService      childScope
    MpNotification.initService childScope


    # --- Listeners ---
    MpProjects.on 'all', =>
      @projects = MpProjects.models

    MpFriends.on 'all', =>
      @friends = MpFriends.models


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
