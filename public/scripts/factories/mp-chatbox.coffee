# MpChatbox
# ========================================
angular.module('mp-chatbox-provider', []).provider 'MpChatbox', class

  setSocketServer: (@socketServer) ->
  setHandshakeQuery: (handshakeQuery) ->
    queryArray = ("#{key}=#{value}" for key, value of handshakeQuery)
    @handshakeQuery = queryArray.join('&')

  # factory
  # ----------------------------------------
  $get: ['$rootScope', '$timeout', '$q', 'Restangular', '$route',
  ($rootScope, $timeout, $q, Restangular, $route) ->

    [socketServer, handshakeQuery] = [@socketServer, @handshakeQuery]
    $friends = Restangular.all 'friends'

    # socket.io
    # ----------------------------------------
    socket =
      socket: null
      online: false
      connect: ->
        defer = $q.defer()
        @socket.socket.connect()
        @on 'connect', =>
          defer.resolve()
          @online = true
        return defer.promise
      disconnect: ->
        @socket.removeAllListeners()
        @socket.disconnect()
        @online = false
      on: (eventName, callback) ->
        @socket.on eventName, (args...) ->
          $timeout -> callback.apply(@socket, args)
      emit: (eventName, data, callback) ->
        @socket.emit eventName, data, (args...) =>
          $rootScope.$apply => callback.apply(@socket, args) if callback

    # socket init
    socketOptions =
      'auto connect': false
      query: handshakeQuery
    socket.socket = io.connect(socketServer, socketOptions)


    # Chatbox
    # ----------------------------------------
    Chatbox =
      rooms: {}
      friends: []
      eventDeregisters: []

      initialize: ->
        $friends.getList().then (friends) =>
          @friends = friends
          friendsIds = _.pluck(friends, 'id')
          socket.emit 'getOnlineFriendsList', friendsIds, (onlineFriendsIds) =>
            console.debug 'Got online friends ids list', onlineFriendsIds
            onlineFriends = _.filter @friends, (friend) ->
              return _.contains(onlineFriendsIds, friend.id)
            _.forEach onlineFriends, (friend) ->
              friend.$$online = true
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
          console.debug @rooms
          # project_id, receivers_ids: []
          data.type = 'message'
          data.user =
            id: $rootScope.User.getId()
            name: $rootScope.User.name()
            fb_user_picture: $rootScope.User.fb_user_picture()
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
              id: $rootScope.User.getId()
              name: $rootScope.User.name()
              fb_user_picture: $rootScope.User.fb_user_picture()
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
        console.debug 'receive serverMessage', data
        switch data.type
          when 'message'
            if @rooms[data.project_id]
              @rooms[data.project_id].push data
            else
              @rooms[data.project_id] = [data]
          when 'addFriendRequest'
            console.debug 'receive addFriendRequest', data

      sendClientMessage: (data) ->
        socket.emit 'clientMessage', data


    # init
    # ----------------------------------------
    # events
    $rootScope.$on '$routeChangeSuccess', (event, current, previous) ->
      if $rootScope.User.checkLogin()
        if !socket.online then socket.connect().then -> Chatbox.initialize()
      else
        if socket.online
          socket.disconnect()
          Chatbox.destroy()


    # return
    # ----------------------------------------
    Chatbox
  ]
