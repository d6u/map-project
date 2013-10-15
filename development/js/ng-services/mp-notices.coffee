app.service 'MpNotices',
['$rootScope','$timeout','$q','Restangular','$route','socket','MpFriends',
 'MpProjects','Backbone',
( $rootScope,  $timeout,  $q,  Restangular,  $route,  socket,  MpFriends,
  MpProjects,  Backbone) ->


  # --- Constants ---
  # directNotificationNames holds notice type that will be added to
  #   @notifications array directive when arrives from server
  DIRECT_NOTICE_TYPES = [
    'addFriendRequest'
    'addFriendRequestAccepted'
    'projectInvitation'
    'projectInvitationAccepted'
    'projectInvitationRejected'
    'newUserAdded'
    'youAreRemovedFromProject'
    'projectUserListUpated'
  ]


  # --- Model ---
  Notice = Backbone.Model.extend {

    initialize: ->
  }


  # --- Collection ---
  MpNotices = Backbone.Collection.extend {

    model: Notice
    url: "/api/notices"


    initialize: ->


    initService: (scope) ->
      @initializing = true
      @fetch({
        reset: true
        success: =>
          delete @initializing
      })

      socket.on 'pushData', (data) =>
        @add(data)

      deregister = scope.$on '$destroy', =>
        @reset()
        socket.removeAllListeners('pushData')
        deregister()
  }
  # END MpNotices


  return new MpNotices
]
