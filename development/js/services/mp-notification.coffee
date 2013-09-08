###
MpNotification
###

app.factory 'MpNotification',
['$rootScope','$timeout','$q','Restangular','$route','socket',
( $rootScope,  $timeout,  $q,  Restangular,  $route,  socket) ->

  $notifications = Restangular.all 'notifications'

  return MpNotification = {
    $online: false
    notifications: []


    # --- Connect to server ---
    connect: (callback) ->
      socket.connect().then =>
        @updateNotifications()
        # onlineFriendsList event is an indicator of server ready
        socket.on 'onlineFriendsList', (onlineFriendsList) =>
          @$$online = true
          $rootScope.$broadcast 'onlineFriendsListUpdated', onlineFriendsList
          socket.on 'serverData', (data) =>
            @processServerData(data)
          callback() if callback


    # --- Close connection and remove data ---
    destroy: ->
      socket.disconnect()
      @$online = false


    # --- Helper ---
    updateNotifications: ->
      $notifications.getList().then (notifications) =>
        if @notifications.length
          # TODO: organize new and existing notifications
          @notifications = notifications
        else
          @notifications = notifications


    processServerData: (data) ->
      console.debug '--> serverData received: ', data
      switch data.type
        when 'addFriendRequest'
          @notifications.push data


    # send data helper
    sendClientData: (data) ->
      socket.emit 'clientData', data
  }
]