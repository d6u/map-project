###
MpNotification
###

app.service 'MpNotification',
['$rootScope', '$timeout', '$q', 'Restangular', '$route', 'socket', class MpNotification

  constructor: ($rootScope, $timeout, $q, Restangular, $route, socket) ->
    @notifications = []

    # --- Resouces ---
    @$$notifications = Restangular.all 'notifications'

    Restangular.addElementTransformer 'notifications', true, (notifications) ->
      for notice in notifications
        notice.id = notice._id.$oid
      return notifications

    Restangular.addElementTransformer 'notifications', false, (notice) ->
      switch notice.type
        when 'addFriendRequest'
          notice.addRestangularMethod 'ignoreFriendRequest', 'remove', 'ignore_friend_request'
      return notice

    # --- Socket.io ---
    socket.on 'serverData', (serverData) =>
      @processServerData(serverData)


  # --- Login/out process management ---
  initialize: (scope) ->
    @getNotifications()

  destroy: ->
    @notifications = []


  # --- Incoming server notices management ---

  # directNotificationNames holds notice type that will be added to
  #   @notifications array directive when arrives from server
  directNotificationNames: [
    'addFriendRequest'
    'addFriendRequestAccepted'
    'projectInvitation'
    'projectInvitationAccepted'
    'projectInvitationRejected'
    'youAreRemovedFromProject'
    'projectDeleted'
  ]

  processServerData: (data) ->
    console.debug '--> serverData received: ', data
    if _.find(@directNotificationNames, data.type)
      @notifications.push data


  # --- Notification interface ---
  getNotifications: ->
    @$$notifications.getList().then (notifications) =>
      if @notifications.length
        # TODO: organize new and existing notifications
        @notifications = notifications
      else
        @notifications = notifications

  removeNotice: (notice) ->
    @notifications = _.without(@notifications, notice)

  sendClientData: (data) ->
    socket.emit 'clientData', data
]