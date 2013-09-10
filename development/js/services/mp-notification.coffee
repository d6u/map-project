###
MpNotification
###

app.factory 'MpNotification',
['$rootScope','$timeout','$q','Restangular','$route','socket',
( $rootScope,  $timeout,  $q,  Restangular,  $route,  socket) ->

  # --- Instance transform ---
  Restangular.addElementTransformer 'notifications', true, (notifications) ->
    for notice in notifications
      notice.id = notice._id.$oid
    return notifications

  Restangular.addElementTransformer 'notifications', false, (notice) ->
    switch notice.type
      when 'addFriendRequest'
        notice.addRestangularMethod 'ignoreFriendRequest', 'remove', 'ignore_friend_request'
    return notice

  # --- Init ---
  $notifications = Restangular.all 'notifications'

  return MpNotification = {
    $online: false
    notifications: []


    # --- Connect to server ---
    connect: (callback) ->
      @updateNotifications()

      # onlineFriendsList event is an indicator of server ready
      socket.on 'onlineFriendsList', (onlineFriendsList) =>
        @$online = true
        $rootScope.$broadcast 'onlineFriendsListUpdated', onlineFriendsList
        socket.on 'serverData', (data) =>
          @processServerData(data)
        callback() if callback

      socket.connect()


    # --- Close connection and remove data ---
    destroy: ->
      socket.disconnect()
      @$online = false


    # --- Callbacks ---
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
      # else


    # --- Notices ---
    updateNotifications: ->
      $notifications.getList().then (notifications) =>
        if @notifications.length
          # TODO: organize new and existing notifications
          @notifications = notifications
        else
          @notifications = notifications


    removeNotice: (notice) ->
      @notifications = _.without(@notifications, notice)


    # --- General helper ---
    sendClientData: (data) ->
      socket.emit 'clientData', data
  }
]