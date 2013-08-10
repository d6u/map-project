app = angular.module 'angular-mp.home.chatbox', ['angular-mp.home.initializer', 'restangular']


# MpChatbox
# ========================================
app.provider 'MpChatbox', class

  setSocketServer: (@socketServer) ->
  setHandshakeQuery: (handshakeQuery) ->
    queryArray = ("#{key}=#{value}" for key, value of handshakeQuery)
    @handshakeQuery = {query: queryArray.join('&')}

  # factory
  # ----------------------------------------
  $get: ['$rootScope', '$timeout', '$q', 'Restangular', '$route',
  ($rootScope, $timeout, $q, Restangular, $route) ->

    chatboxReady = $q.defer()
    $friends = Restangular.all 'friends'

    # socket.io
    socket =
      socket: null
      on: (eventName, callback) ->
        @socket.on eventName, (args...) ->
          $timeout -> callback.apply(@socket, args)
      emit: (eventName, data, callback) ->
        @socket.emit eventName, data, (args...) =>
          $rootScope.$apply => callback.apply(@socket, args) if callback

    # Chatbox
    Chatbox =
      chatHistory: []
      friends: []
      onlineFriendsIds: []
      partcipatedUsers: []

      initialize: ->
        $friends.getList().then (friends) =>
          @friends = friends
          friendsIds = _.pluck(friends, 'id')
          if $route.current.$$route.controller == 'ProjectViewCtrl'
            Chatbox.loadParticipatedUser($route.current.params.project_id)
          $rootScope.$on '$routeChangeSuccess', (event, current) =>
            if $route.current.$$route.controller == 'ProjectViewCtrl'
              Chatbox.loadParticipatedUser($route.current.params.project_id)
            else
              @partcipatedUsers = []
          socket.emit 'getOnlineFriendsList', friendsIds, (onlineFriendsIds) =>
            console.log 'getOnlineFriendsList', onlineFriendsIds
            @onlineFriendsIds = onlineFriendsIds
        socket.on 'userConnected', (userId) =>
          console.log 'userConnected', userId
          if _.indexOf(@onlineFriendsIds, userId) == -1
            @onlineFriendsIds.push userId
        socket.on 'userDisconnected', (userId) =>
          console.log 'userDisconnected', userId
          @onlineFriendsIds = _.without(@onlineFriendsIds, userId)

      loadParticipatedUser: (projectId) ->
        $project = Restangular.one('projects', projectId).getList('users')
        .then (users) =>
          usersIds = _.pluck users, 'id'
          for friend in @friends
            if _.indexOf(usersIds, friend.id) != -1
              @partcipatedUsers.push friend


    # init
    # ----------------------------------------
    $rootScope.$on 'userLoggedIn', =>
      socket.socket = if @socketServer then io.connect(@socketServer, @handshakeQuery) else io.connect(undefined, @handshakeQuery)
      chatboxReady.resolve(Chatbox)
      socket.on 'connect', ->
        Chatbox.initialize()
    $rootScope.$on 'userLoggedOut', ->
      socket.socket = null
      chatboxReady.resolve(Chatbox)


    # watcher
    # ----------------------------------------
    # $watch for Chatbox.onlineFriendsIds
    $rootScope.$watch ((currentScope) ->
      Chatbox.onlineFriendsIds.sort()
    ), ((newVal, oldVal, currentScope) ->
      markOnlineFriends()
    ), true

    # $watch for Chatbox.friends
    $rootScope.$watch ((currentScope) ->
      friendsIds = _.pluck(Chatbox.friends, 'id')
      friendsIds.sort()
    ), ((newVal, oldVal, currentScope) ->
      markOnlineFriends()
    ), true

    markOnlineFriends = ->
      for friend in Chatbox.friends
        if _.indexOf(Chatbox.onlineFriendsIds, friend.id) != -1
          friend.$$online = true
        else
          friend.$$online = false


    # return
    # ----------------------------------------
    return chatboxReady.promise
  ]


# mp-chatbox
# ========================================
app.directive 'mpChatbox', ['$templateCache', '$compile', 'Invitation',
'$route',
($templateCache, $compile, Invitation, $route)->

  templateUrl: 'mp_chatbox_template'
  link: (scope, element, attrs) ->

    scope.expandChatbox = ->
      element.addClass 'mp-chatbox-show'
      template = $templateCache.get 'mp_chatbox_template_expanded'
      element.html $compile(template)(scope)

    scope.collapseChatbox = ->
      element.removeClass 'mp-chatbox-show'
      template = $templateCache.get 'mp_chatbox_template'
      element.html $compile(template)(scope)
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
