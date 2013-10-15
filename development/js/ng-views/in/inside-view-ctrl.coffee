app.controller 'InsideViewCtrl',
['$scope','MpProjects','MpNotices','$location','MpFriends','socket',
 'MpUser', class InsideViewCtrl

  constructor: ($scope, MpProjects, MpNotices, $location, MpFriends, socket, MpUser) ->

    # --- Properties ---
    @MpUser = MpUser


    # --- Init Services ---
    socket.connect()

    childScope = $scope.$new()

    MpProjects.initService childScope
    MpFriends.initService  childScope
    MpNotices.initService  childScope


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
