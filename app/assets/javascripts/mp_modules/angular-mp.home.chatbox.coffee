app = angular.module 'angular-mp.home.chatbox', ['angular-mp.home.initializer', 'restangular']


# MpChatbox
# ========================================
app.provider 'MpChatbox', class

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
        socket.on 'serverMessage', (data) ->
          processServerMessage(data)
        @eventDeregisters.push($rootScope.$on 'enterNewMessage', (event, data) =>
          console.debug @rooms
          data.sender_id = $rootScope.User.getId()
            # project_id, receivers_ids: []
          data.type = 'message'
          data.sender_name = $rootScope.User.name()
          data.sender_fb_user_picture = $rootScope.User.fb_user_picture()
          @sendClientMessage(data)
          data.self = true
          $rootScope.$apply =>
            if @rooms[data.project_id]
              @rooms[data.project_id].push data
            else
              @rooms[data.project_id] = [data]
        )

      destroy: ->
        [@rooms, @friends] = [[], []]
        # remove all listeners
        for eventDeregister in @eventDeregisters
          eventDeregister()

      processServerMessage: (data) ->

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


# mp-chatbox
# ========================================
app.directive 'mpChatbox', ['$templateCache', '$compile', 'Invitation',
'$route', 'Restangular', 'MpProjects', '$timeout',
($templateCache, $compile, Invitation, $route, Restangular, MpProjects,
 $timeout)->

  templateUrl: 'mp_chatbox_template'
  link: (scope, element, attrs) ->

    scope.expandChatbox = ->
      element.addClass 'mp-chatbox-show'
      template = $templateCache.get 'mp_chatbox_template_expanded'
      element.html $compile(template)(scope)

      # TODO: improve
      # this is used to scroll to bottom of chat historys
      $timeout (->
        chatHistoryBox = element.find('.mp-chat-history')
        lastChild = chatHistoryBox.children('.mp-chat-history-item').last()
        console.debug lastChild
        if lastChild.length > 0
          scrollTop = lastChild.position().top + 10 + lastChild.height() - chatHistoryBox.height()
          chatHistoryBox.animate({scrollTop: scrollTop}, 150, ->
            chatHistoryBox.perfectScrollbar 'update'
          )
      ), 300

    scope.collapseChatbox = ->
      element.removeClass 'mp-chatbox-show'
      template = $templateCache.get 'mp_chatbox_template'
      element.html $compile(template)(scope)

    # init
    # TODO: load participated users
    # console.debug MpProjects.currentProject
    scope.$watch(
      (() ->
        return MpProjects.currentProject.id
      ),
      ((newVal, oldVal) ->
        $project = Restangular.one('projects', newVal).getList('users').then (users) -> scope.participatedUsers = users
      )
    )
]


# mp-chat-history
app.directive 'mpChatHistory', ['MpChatbox', '$route', (MpChatbox, $route) ->
  (scope, element, attrs) ->

    project_id = Number($route.current.params.project_id)

    if !MpChatbox.rooms[project_id]
      MpChatbox.rooms[project_id] = []
    scope.chatHistory = MpChatbox.rooms[project_id]
    console.debug 'MpChatbox.rooms', MpChatbox.rooms

    # watch for changed in chat history and determine whether to scroll down to
    #   newest item
    for value in attrs.perfectScrollbar.split(',')
      scope.$watch value, (newValue, oldValue, scope) ->

        lastChild = element.children('.mp-chat-history-item').last()

        if lastChild.length > 0
          elementHeight     = element.height()
          lastChildToTop    = lastChild.position().top + 5
          lastChildToBottom = lastChildToTop - elementHeight

          if lastChildToBottom < 40
            totalHeight = element.scrollTop() + lastChildToTop + 5 + lastChild.height()
            scrollTop = totalHeight - elementHeight
            element.stop().animate {scrollTop: scrollTop}, 100, ->
              element.perfectScrollbar 'update'
]


# mp-chatbox-input
app.directive 'mpChatboxInput', ['$route', ($route) ->
  (scope, element, attrs) ->

    element.on 'keydown', (event) ->
      if event.keyCode == 13
        if element.val() != ''
          console.debug scope.participatedUsersIds, scope.chatHistory
          data =
            project_id: Number($route.current.params.project_id)
            receivers_ids: _.pluck(scope.participatedUsers, 'id')
            body:
              message: element.val()
          scope.$emit 'enterNewMessage', data
          element.val ''
        return false
      return undefined
]


# mp-chat-history-item
app.directive 'mpChatHistoryItem', ['$compile', '$templateCache', '$rootScope',
($compile, $templateCache, $rootScope) ->

  chooseTemplate = (type) ->
    switch type
      when 'message'
        return $templateCache.get 'chat_history_message_template'
      when 'userBehavior'
        return $templateCache.get 'chat_history_user_behavior_template'
      when 'addPlaceToList'
        return $templateCache.get 'chat_history_place_template'

  # return
  link: (scope, element, attrs) ->
    if scope.chatItem.type == 'addPlaceToList' && !scope.chatItem.self
      scope.ActiveProject.project.one('places', scope.chatItem.placeId).get().then (place) ->
        scope.chatItem.placeName = place.name
        scope.chatItem.placeAddress = place.address
        $rootScope.$broadcast 'updateInPlacesList'
    template = chooseTemplate scope.chatItem.type
    element.html $compile(template)(scope)
    if scope.chatItem.self
      element.addClass 'mp-chat-history-self'
]
