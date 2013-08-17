# MpChatbox
# ========================================
angular.module('mp-chatbox-provider', []).provider 'MpChatbox', class

  setSocketServer: (@$$socketServer) ->
  setHandshakeQuery: (handshakeQuery) ->
    queryArray = ("#{key}=#{value}" for key, value of handshakeQuery)
    @handshakeQuery = queryArray.join('&')

  # factory
  # ----------------------------------------
  $get: ['$rootScope', '$timeout', '$q', 'Restangular', '$route',
  ($rootScope, $timeout, $q, Restangular, $route) ->

    [socketServer, handshakeQuery] = [@$$socketServer, @handshakeQuery]
    $friendships   = Restangular.all 'friendships'
    $friends       = Restangular.all 'friends'
    $notifications = Restangular.all 'notifications'

    # socket.io
    # ----------------------------------------
    socket =
      $$socket: null
      online: false
      connect: ->
        defer = $q.defer()
        @$$socket.socket.connect()
        @on 'connect', =>
          defer.resolve()
          @online = true
        return defer.promise
      disconnect: ->
        @$$socket.removeAllListeners()
        @$$socket.disconnect()
        @online = false
      on: (eventName, callback) ->
        @$$socket.on eventName, (args...) ->
          $timeout -> callback.apply(@$$socket, args)
      emit: (eventName, data, callback) ->
        @$$socket.emit eventName, data, (args...) =>
          $rootScope.$apply => callback.apply(@$$socket, args) if callback

    # socket init
    socketOptions =
      'auto connect': false
      query: handshakeQuery
    socket.$$socket = io.connect(socketServer, socketOptions)


    # MpChatbox
    # ----------------------------------------
    MpChatbox =
      socket: socket
      rooms: {}
      friends: []
      eventDeregisters: []
      notifications: []
      # this is a project related property, if user is a friend, object from
      #   friends property will be referred, otherwise will refer to object in
      #   __participatedUsers
      participatedUsers: []
      __participatedUsers: [] # used to store orginal server object

      initialize: ->
        $notifications.getList().then (notifications) =>
          @notifications.push notice for notice in notifications
        @updateFriendsList()
        # setup listeners
        socket.on 'userConnected', (userId) =>
          console.debug 'userConnected', userId
          friend = _.find @friends, {id: userId}
          friend.$$online = true
        socket.on 'userDisconnected', (userId) =>
          console.debug 'userDisconnected', userId
          friend = _.find @friends, {id: userId}
          delete friend.$$online
        socket.on 'serverMessage', (data) =>
          @processServerMessage(data)

        # register scope listeners
        enterNewMessage = $rootScope.$on 'enterNewMessage', (event, data) =>
          console.debug 'enterNewMessage @rooms ->', @rooms
          # project_id, receivers_ids: []
          data.type = 'message'
          data.user =
            id: $rootScope.MpUser.getId()
            name: $rootScope.MpUser.name()
            fb_user_picture: $rootScope.MpUser.fb_user_picture()
          @sendClientMessage(data)
          data.self = true
          $rootScope.$apply =>
            if @rooms[data.project_id]
              @rooms[data.project_id].push data
            else
              @rooms[data.project_id] = [data]

        addFriendRequest = $rootScope.$on 'addFriendRequest', (event, friend_id) =>
          console.debug 'addFriendRequest', friend_id
          data =
            type: 'addFriendRequest'
            sender:
              id: $rootScope.MpUser.getId()
              name: $rootScope.MpUser.name()
              fb_user_picture: $rootScope.MpUser.fb_user_picture()
            receivers_ids: [friend_id]
          @sendClientMessage(data)

        # save for future deregistration
        @eventDeregisters.push enterNewMessage
        @eventDeregisters.push addFriendRequest

      destroy: ->
        [@rooms, @friends] = [[], []]
        # remove all listeners
        for eventDeregister in @eventDeregisters
          eventDeregister()

      processServerMessage: (data) ->
        switch data.type
          when 'message'
            if @rooms[data.project_id]
              @rooms[data.project_id].push data
            else
              @rooms[data.project_id] = [data]
          when 'addFriendRequest'
            if !_.find @notifications, {body: {friendship_id: data.body.friendship_id}}
              @notifications.push data

      sendClientMessage: (data) ->
        @socket.emit 'clientMessage', data

      # specific actions
      # ----------------------------------------
      # used in mp-user-section
      updateFriendsList: ->
        $friends.getList().then (friends) =>
          @friends = friends
          friendsIds = _.pluck(friends, 'id')
          socket.emit 'getOnlineFriendsList', friendsIds, (onlineFriendsIds) =>
            onlineFriends = _.filter @friends, (friend) ->
              return _.contains(onlineFriendsIds, friend.id)
            _.forEach onlineFriends, (friend) ->
              friend.$$online = true

      # friend request handling
      sendFriendRequest: (user) ->
        $friendships.post({friend_id: user.id, status: 0}).then(
          ((friendship) ->
            data = {
              type: 'addFriendRequest'
              sender:
                id:              $rootScope.MpUser.getId()
                name:            $rootScope.MpUser.name()
                fb_user_picture: $rootScope.MpUser.fb_user_picture()
              receivers_ids:     [user.id]
              body:
                friendship_id:   friendship.id
            }
            MpChatbox.sendClientMessage(data)
          ),
          # client error, most likly due to duplicate requests, all blocked
          ((error) ->
            user.systemMessage = error.data.message if error.data.error == true
          )
        )

      acceptFriendRequest: (notice) ->
        friendship = Restangular.one('friendships', notice.body.friendship_id)
        friendship.status = 1
        friendship.put().then(
          ((friend) ->
            MpChatbox.notifications = _.without MpChatbox.notifications, notice
            MpChatbox.friends.push friend
          ),
          (->
            MpChatbox.notifications = _.without MpChatbox.notifications, notice
          )
        )

      ignoreFriendRequest: (notice) ->
        MpChatbox.notifications = _.without MpChatbox.notifications, notice
        friendship = Restangular.one('friendships', notice.body.friendship_id)
        friendship.remove()


    # watcher
    # ----------------------------------------
    # watch for changes in participated users, mark online users automatically
    $rootScope.$watch(
      (->
        return (_.pluck MpChatbox.__participatedUsers, 'id').sort()
      ),
      ((newVal, oldVal) ->
        MpChatbox.participatedUsers = []
        _.forEach MpChatbox.__participatedUsers, (user, index) ->
          friend = _.find MpChatbox.friends, {id: user.id}
          if friend
            MpChatbox.participatedUsers[index] = friend
          else if user.id == $rootScope.MpUser.getId()
            $rootScope.MpUser.$$user.$$online = true
            MpChatbox.participatedUsers[index] = $rootScope.MpUser.$$user
          else
            MpChatbox.participatedUsers[index] = user
      ), true
    )


    # return
    # ----------------------------------------
    return MpChatbox
  ]
