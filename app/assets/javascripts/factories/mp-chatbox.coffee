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
      connect: ->
        defer = $q.defer()
        @$$socket.socket.connect()
        @on 'connect', =>
          defer.resolve()
        return defer.promise
      disconnect: ->
        @$$socket.removeAllListeners()
        @$$socket.disconnect()
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
      $$online: false
      rooms: {}
      notifications: []
      friends: []
      scopeListeners: []

      connect: (callback) ->
        socket.connect().then =>
          # get data
          $notifications.getList().then (notifications) =>
            @notifications.push notice for notice in notifications
          @updateFriendsList()
          # socket listeners
          socket.on 'userConnected', (userId) =>
            console.debug 'userConnected', userId
            friend = _.find @friends, {id: userId}
            friend.$$online = true
          socket.on 'userDisconnected', (userId) =>
            console.debug 'userDisconnected', userId
            friend = _.find @friends, {id: userId}
            delete friend.$$online if friend.$$online
          socket.on 'serverData', (data) =>
            @processServerData(data)
          # change status
          @$$online = true
          # exe callback
          callback()


      updateFriendsList: ->
        $friends.getList().then (friends) =>
          @friends = friends
          friendsIds = _.pluck(friends, 'id')
          socket.emit 'getOnlineFriendsList', friendsIds, (onlineFriendsIds) =>
            onlineFriends = _.filter @friends, (friend) ->
              return _.contains(onlineFriendsIds, friend.id)
            _.forEach onlineFriends, (friend) ->
              friend.$$online = true

      # send data helper
      sendClientData: (data) ->
        @socket.emit 'clientData', data

      processServerData: (data) ->
        switch data.type
          when 'addFriendRequest'
            if !_.find @notifications, {body: {friendship_id: data.body.friendship_id}}
              @notifications.push data
          when 'friendAcceptNotice'
            @updateFriendsList()
            @notifications.push data

          # when 'message'
          #   if @rooms[data.project_id]
          #     @rooms[data.project_id].push data
          #   else
          #     @rooms[data.project_id] = [data]


      # global
      # ----------------------------------------
      sendFriendRequest: (friendship) ->
        MpChatbox.sendClientData({
          type: 'addFriendRequest'
          sender:
            id:              $rootScope.MpUser.getId()
            name:            $rootScope.MpUser.name()
            fb_user_picture: $rootScope.MpUser.fb_user_picture()
          receivers_ids:     [friendship.friend_id]
          body:
            friendship_id:   friendship.id
        })

      sendFriendAcceptNotice: (friend) ->
        MpChatbox.sendClientData({
          type: 'friendAcceptNotice'
          sender:
            id:              $rootScope.MpUser.getId()
            name:            $rootScope.MpUser.name()
            fb_user_picture: $rootScope.MpUser.fb_user_picture()
          receivers_ids:     [friend.id]
        })

      sendProjectInvitation: () ->


      # project
      # ----------------------------------------
      sendChatMessage: () ->

      sendActionAboutPlace: () ->





      initialize: ->
        # register scope listeners
        # enterNewMessage = $rootScope.$on 'enterNewMessage', (event, data) =>
        #   console.debug 'enterNewMessage @rooms ->', @rooms
        #   # project_id, receivers_ids: []
        #   data.type = 'message'
        #   data.user =
        #     id: $rootScope.MpUser.getId()
        #     name: $rootScope.MpUser.name()
        #     fb_user_picture: $rootScope.MpUser.fb_user_picture()
        #   @sendClientMessage(data)
        #   data.self = true
        #   $rootScope.$apply =>
        #     if @rooms[data.project_id]
        #       @rooms[data.project_id].push data
        #     else
        #       @rooms[data.project_id] = [data]

        # addFriendRequest = $rootScope.$on 'addFriendRequest', (event, friend_id) =>
        #   console.debug 'addFriendRequest', friend_id
        #   data =
        #     type: 'addFriendRequest'
        #     sender:
        #       id: $rootScope.MpUser.getId()
        #       name: $rootScope.MpUser.name()
        #       fb_user_picture: $rootScope.MpUser.fb_user_picture()
        #     receivers_ids: [friend_id]
        #   @sendClientMessage(data)

        # # save for future deregistration
        # @eventDeregisters.push enterNewMessage
        # @eventDeregisters.push addFriendRequest

      destroy: ->
        @$$online = true
        @socket.disconnect()
        [@rooms, @friends] = [[], []]
        # remove all listeners
        # for eventDeregister in @eventDeregisters
        #   eventDeregister()


    # return
    # ----------------------------------------
    return MpChatbox
  ]
