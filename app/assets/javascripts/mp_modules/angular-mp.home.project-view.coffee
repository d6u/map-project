app = angular.module 'angular-mp.home.project-view', []


app.controller 'ProjectViewCtrl',
['$scope', 'Project', '$location', '$rootScope', '$q', '$timeout',
 '$templateCache', '$compile', '$route',
($scope, Project, $location, $rootScope, $q, $timeout,
 $templateCache, $compile, $route) ->

  # callbacks
  loadPlaceOntoMap = (place) ->
    coordMatch = /\((.+), (.+)\)/.exec place.coord
    latLog = new google.maps.LatLng coordMatch[1], coordMatch[2]
    markerOptions =
      map: $scope.googleMap.map
      title: place.name
      position: latLog
      icon:
        url: "/assets/number_#{place.order}.png"

    place.$$marker = new google.maps.Marker markerOptions


  savePlace = (place) ->
    place.id = null
    places = $scope.currentProject.project.all('places')
    places.post(place).then (newPlace) ->
      angular.extend place, newPlace

  # init
  if $scope.user.fb_access_token
    # login with unsaved places
    Project.customGET($route.current.params.project_id).then (project) ->
      $scope.currentProject.project = project
      project.all('places').getList().then (places) ->
        $scope.currentProject.places = places
        $scope.googleMap.mapReady.promise.then ->
          loadPlaceOntoMap place for place in $scope.currentProject.places

  # events
  $scope.$on 'placeAddedToList', (event, place) ->
    savePlace(place)

  $scope.$on 'placeRemovedFromList', (event, place) ->
    place.$$marker = null
    place.remove()

  $scope.$on 'projectUpdated', (event, project) ->
    $scope.currentProject.project = project
]


# ChatBoxCtrl
app.controller 'ChatBoxCtrl',
['$scope', 'Friendship', 'Invitation', 'socket', 'Chatbox', '$route',
($scope, Friendship, Invitation, socket, Chatbox, $route) ->

  $scope.addFriendsToProject = ->
    $scope.friendships = []

    $scope.currentProject.projectParticipatedUsers = []
    $scope.currentProject.project.getParticipatedUser().then (users) ->
      $scope.currentProject.projectParticipatedUsers = users
      Friendship.getList().then (friendships)->
        $scope.friendships = friendships

    $scope.$broadcast 'showAddFriendsModal'

  $scope.getInvitationCode = ->
    Invitation.generate($scope.currentProject.project.id).then (code) ->
      $scope.invitationCode = location.origin + '/invitation/join/' + code

  $scope.invite = ->
    for friendship in $scope.friendships
      do (friendship) ->
        if friendship.$$selected
          $scope.currentProject.project.addParticipatedUser(friendship.friend)

  # init
  Chatbox.then (Chatbox) ->

    # callbacks
    joinRoomCallback = ->
      $scope.$on 'enterNewMessage', (event, message) ->
        Chatbox.sendMessage message
      Chatbox.receiveMessage messageCallback

    messageCallback = (content) ->
      # TODO

    Chatbox.joinRoom $route.current.params.project_id, joinRoomCallback
    $scope.chatHistory = Chatbox.chatHistory
    $scope.$watch 'chatHistory.length', (newVal, oldVal, scope) ->
      # TODO
      # console.log Chatbox.chatHistory

    # events
    $scope.$on '$routeChangeStart', (event, future, current) ->
      Chatbox.leaveRoom $route.current.params.project_id
]


# live chat service
app.factory 'Chatbox', ['socket', '$rootScope', '$q',
(socket, $rootScope, $q) ->

  ChatboxReady = $q.defer()

  # wait for socket to connect
  socket.then (socket) ->

    # regular
    ChatboxService =
      joinRoom: (roomId, callback) ->
        socket.emit 'joinRoom', roomId, callback

      leaveRoom: (roomId, callback) ->
        if roomId
          socket.emit 'leaveRoom', roomId, callback
        else
          socket.emit 'leaveRoom', undefined, callback
        socket.socket.removeAllListeners 'chatContent'

      sendMessage: (message) ->
        messageData =
          type: 'message'
          content: message
          fb_user_picture: $rootScope.user.fb_user_picture
        socket.emit 'chatContent', messageData
        messageData.self = true
        @chatHistory.push messageData
        $rootScope.$apply()

      receiveMessage: (messageCallback) ->
        socket.on 'chatContent', (data) =>
          @chatHistory.push data
          switch data.type
            when 'message'
              messageCallback(data.content)

      chatHistory: []

    # resolver
    ChatboxReady.resolve ChatboxService

  # return
  ChatboxReady.promise
]


# invite-friend-list-item
app.directive 'inviteFriendListItem', [->
  (scope, element, attrs) ->

    # init
    scope.friendship.$$selected = if _.find(scope.currentProject.projectParticipatedUsers, {id: scope.friendship.friend.id}) then true else false

    # actions
    scope.selectFriend = ->
      scope.friendship.$$selected = !scope.friendship.$$selected
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
    html = $compile(template)(scope)
    element.append html
    if scope.chatItem.self
      element.addClass 'mp-chat-history-self'
]


