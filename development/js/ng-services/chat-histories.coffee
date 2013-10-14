app.factory 'ChatHistories',
['socket','MpUser','ParticipatingUsers','Backbone',
( socket,  MpUser,  ParticipatingUsers,  Backbone) ->


  # --- Model ---
  ChatHistory   = Backbone.Model.extend {
    initialize: (attrs, options) ->
      if options.selfSender || attrs.user_id == MpUser.getId()
        @$selfSender = true
        @$sender = MpUser.getUser()
      else
        @$sender = options.sender || ParticipatingUsers.get(attrs.user_id)

      @on 'sync', (model, resp, options) ->
        delete model.$sending
  }


  # --- Collection ---
  ChatHistories = Backbone.Collection.extend {

    model: ChatHistory
    comparator: 'id'

    initialize: () ->
      @on 'request', (model, xhr, options) ->
        model.$sending = true

      socket.on 'serverData', (data) =>
        if data.type == 'chatMessage'
          @add({
            item_type: 0
            content:
              m: data.message
          })


    initProject: (id, scope) ->
      @$scope = scope
      @url    = "/api/projects/#{id}/chat_histories"
      @fetch({reset: true})

      @$scope.$on '$destroy', =>
        delete @$scope
        @reset()
  }
  # END ChatHistories


  return new ChatHistories
]
