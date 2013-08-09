app = angular.module 'angular-mp.home.chatbox', []


# live chat service
# ========================================
app.factory 'Chatbox', ['$rootScope', '$q',
($rootScope, $q) ->

  # regular
  ChatboxService =
    chatHistory: []
    rooms: []
    socket: null

    setSocket: (socket) ->
      @socket = socket

    joinRoom: (roomId, callback) ->
      @rooms.push roomId
      @socket.emit 'joinRoom', roomId, callback

    leaveRoom: (roomId, callback) ->
      if roomId
        @socket.emit 'leaveRoom', roomId, callback
      else
        @socket.emit 'leaveRoom', undefined, callback
      @socket.socket.removeAllListeners 'chatContent'

    sendMessage: (message) ->
      messageData =
        type: 'message'
        content: message
        fb_user_picture: $rootScope.User.$$user.fb_user_picture
      @socket.emit 'chatContent', messageData
      messageData.self = true
      @chatHistory.push messageData
      $rootScope.$apply()

    receiveMessage: (messageCallback, userBehaviorCallback) ->
      @socket.on 'chatContent', (data) =>
        @chatHistory.push data
        switch data.type
          when 'message'
            messageCallback(data.content)
          when 'userBehavior'
            userBehaviorCallback(data)

    reset: ->
      socket = null
      @chatHistory = []
      @leaveRoom roomId for roomId in @rooms
      @rooms = []


  return ChatboxService
]


# mp-chatbox
# ========================================
app.directive 'mpChatbox', ['$templateCache', '$compile',
'Friendship', 'Invitation', 'socket', 'Chatbox', '$route',
($templateCache, $compile,
 Friendship, Invitation, socket, Chatbox, $route)->

  templateUrl: 'mp_chatbox_template'
  link: (scope, element, attrs) ->

    # callbacks
    messageCallback = (content) ->
      # TODO

    userBehaviorCallback = (data) ->
      if data.event == 'joinRoom'
        data.description = 'just joined.'
        scope.ActiveProject.roomClientIds[data.userId] = true
      else if data.event == 'leaveRoom'
        data.description = 'just left.'
        scope.ActiveProject.roomClientIds[data.userId] = false
      onlineCheck()


    joinRoomCallback = (userIds) ->
      scope.$on 'enterNewMessage', (event, message) ->
        Chatbox.sendMessage message
      Chatbox.receiveMessage messageCallback, userBehaviorCallback
      for id in userIds
        scope.ActiveProject.roomClientIds[id] = true


    onlineCheck = ->
      for user in scope.ActiveProject.partcipatedUsers
        if scope.ActiveProject.roomClientIds[user.id]
          user.online = true
        else
          user.online = false

    # init
    Chatbox.setSocket scope.socket
    Chatbox.joinRoom $route.current.params.project_id, joinRoomCallback
    scope.chatHistory = Chatbox.chatHistory

    scope.expandChatbox = ->
      element.addClass 'mp-chatbox-show'
      template = $templateCache.get 'mp_chatbox_template_expanded'
      element.html $compile(template)(scope)

    scope.collapseChatbox = ->
      element.removeClass 'mp-chatbox-show'
      template = $templateCache.get 'mp_chatbox_template'
      element.html $compile(template)(scope)


    scope.$watch 'ActiveProject.partcipatedUsers.length', (newVal, oldVal) ->
      onlineCheck()

    scope.$on '$routeChangeStart', (event, future, current) ->
      Chatbox.reset()
]


# mp-chat-history
app.directive 'mpChatHistory', [->
  (scope, element, attrs) ->

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
app.directive 'mpChatboxInput', [->
  (scope, element, attrs) ->

    element.on 'keydown', (event) ->
      if event.keyCode == 13
        if element.val() != ''
          scope.$emit 'enterNewMessage', element.val()
          element.val ''
        return false
      return undefined
]


# mp-chat-history-item
app.directive 'mpChatHistoryItem', ['$compile', '$templateCache',
($compile, $templateCache) ->

  chooseTemplate = (type) ->
    switch type
      when 'message'
        return $templateCache.get 'chat_history_message_template'
      when 'userBehavior'
        return $templateCache.get 'chat_history_user_behavior_template'

  # return
  link: (scope, element, attrs) ->
    template = chooseTemplate scope.chatItem.type
    element.html $compile(template)(scope)
    if scope.chatItem.self
      element.addClass 'mp-chat-history-self'
]
