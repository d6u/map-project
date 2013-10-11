app.factory 'ChatHistories',
['socket','TheProject','$routeSegment','MpUser','MpFriends',
( socket,  TheProject,  $routeSegment,  MpUser,  MpFriends) ->


  # --- Model ---
  ChatHistory   = Backbone.Model.extend {
    initialize: (attrs, options) ->
      if options.selfSender || attrs.user_id == MpUser.getId()
        @$selfSender = true
        @$sender = MpUser.getUser()

      @on 'sync', (model, resp, options) ->
        delete model.$sending
  }


  # --- Collection ---
  ChatHistories = Backbone.Collection.extend {

    model: ChatHistory

    initialize: () ->
      @on 'request', (model, xhr, options) ->
        model.$sending = true

      @on 'sync', (model, resp, options) ->


    initProject: (id, scope) ->
      @$scope = scope
      @url    = "/api/projects/#{id}/chat_histories"
      @fetch({reset: true})
  }


  return new ChatHistories




  # --- Enter/leave project view management ---
  # initialize: (@scope) ->
  #   @chatHistory = []

  #   scope.$on '$destroy', (event) =>
  #     @destroy()

  #   @socket.on 'chatMessage', (data) =>
  #     @chatHistory.push data

  #   @socket.on 'serverData', (data) =>
  #     if data.type == 'placeAdded'
  #       @chatHistory.push data

  #   scope.$watch (=>
  #     _.map @TheProject.participatedUsers.sort(), (friend) =>
  #       {id: friend.id, online: !!friend.$online}
  #   ), ((newVal, oldVal) =>
  #     return if !oldVal
  #     for friend, idx in @TheProject.participatedUsers
  #       if friend.$online != _.find(oldVal, {id: friend.id})?.online
  #         if friend.$online
  #           @chatHistory.push {
  #             type: 'userBehavior'
  #             message: "#{friend.name} comes online."
  #           }
  #         else
  #           @chatHistory.push {
  #             type: 'userBehavior'
  #             message: "#{friend.name} has gone offline."
  #           }
  #   ), true

  # destroy: ->
  #   @socket.$$socket.removeAllListeners 'chatMessage'
  #   @chatHistory = []


  # # --- Real time messaging helper ---
  # sendChatMessage: (message) ->
  #   @scope.$apply =>
  #     @chatHistory.push {
  #       type:    'chatMessage'
  #       sender:  @MpUser.getUser()
  #       message: message
  #       $self:   true
  #     }
  #   @socket.emit 'chatMessage', {
  #     message: message
  #     project_id: @TheProject.project.id
  #   }
]
