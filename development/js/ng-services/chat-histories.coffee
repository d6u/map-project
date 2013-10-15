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

      socket.on 'chatData', (data) =>
        @add(data)


    initProject: (id, scope) ->
      @url = "/api/projects/#{id}/chat_histories"
      @fetch({reset: true})

      scope.$on '$destroy', =>
        @reset()
  }
  # END ChatHistories


  return new ChatHistories
]
