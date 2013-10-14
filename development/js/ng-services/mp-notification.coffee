app.service 'MpNotification',
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
  MpNotification = Backbone.Collection.extend {

    model: Notice
    url: "/api/notifications"


    initialize: ->


    initService: (scope) ->
      @fetch({reset: true})

      socket.on 'pushData', (data) =>
        console.debug 'pushData', data

      deregister = scope.$on '$destroy', =>
        @reset()
        socket.removeAllListeners('pushData')
        deregister()
  }
  # END MpNotification


  return new MpNotification


  # --- Incoming server notices management ---
]
