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

    receiveMessage: (messageCallback) ->
      @socket.on 'chatContent', (data) =>
        @chatHistory.push data
        switch data.type
          when 'message'
            messageCallback(data.content)

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
    joinRoomCallback = (userIds) ->
      scope.$on 'enterNewMessage', (event, message) ->
        Chatbox.sendMessage message
      Chatbox.receiveMessage messageCallback
      for id in userIds
        scope.ActiveProject.roomClientIds[id] = true

    messageCallback = (content) ->
      # TODO

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

    scope.$watch 'ActiveProject.roomClientIds.length', (newVal, oldVal) ->
      onlineCheck()








    # $scope.addFriendsToProject = ->
    #   $scope.friendships = []

    #   $scope.currentProject.projectParticipatedUsers = []
    #   $scope.currentProject.project.getParticipatedUser().then (users) ->
    #     $scope.currentProject.projectParticipatedUsers = users
    #     Friendship.getList().then (friendships)->
    #       $scope.friendships = friendships

    #   $scope.$broadcast 'showAddFriendsModal'

    # $scope.getInvitationCode = ->
    #   Invitation.generate($scope.currentProject.project.id).then (code) ->
    #     $scope.invitationCode = location.origin + '/invitation/join/' + code

    # $scope.invite = ->
    #   for friendship in $scope.friendships
    #     do (friendship) ->
    #       if friendship.$$selected
    #         $scope.currentProject.project.addParticipatedUser(friendship.friend)

    # events
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


# # invite-friend-list-item
# app.directive 'inviteFriendListItem', [->
#   (scope, element, attrs) ->

#     # init
#     scope.friendship.$$selected = if _.find(scope.currentProject.projectParticipatedUsers, {id: scope.friendship.friend.id}) then true else false

#     # actions
#     scope.selectFriend = ->
#       scope.friendship.$$selected = !scope.friendship.$$selected
# ]


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

  # return
  link: (scope, element, attrs) ->
    template = chooseTemplate scope.chatItem.type
    element.html $compile(template)(scope)
    if scope.chatItem.self
      element.addClass 'mp-chat-history-self'
]
