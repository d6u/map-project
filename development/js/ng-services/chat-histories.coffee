app.factory 'ChatHistories',
['MpUser','ParticipatingUsers','Backbone','MapPlaces','$q','PushDispatcher',
( MpUser,  ParticipatingUsers,  Backbone,  MapPlaces,  $q,  PushDispatcher) ->


  # --- Model ---
  ChatHistory   = Backbone.Model.extend {
    initialize: (attrs, options) ->
      if options.selfSender || attrs.user_id == MpUser.getId()
        @$selfSender = true
        @$sender = MpUser.getUser()
      else
        @$sender = options.sender || ParticipatingUsers.get(attrs.user_id)

      switch attrs.item_type
        when 1 then @$place = MapPlaces.get(attrs.content.pl_id)

      @on 'sync', (model, resp, options) ->
        delete model.$sending
  }


  # --- Collection ---
  ChatHistories = Backbone.Collection.extend {

    model: ChatHistory
    comparator: 'id'

    initialize: ->
      @serviceReadyCount = 0

      ParticipatingUsers.while 'service:ready', =>
        @serviceReadyCount++
        @trigger('dependency:ready')
      MapPlaces.while 'service:ready', =>
        @serviceReadyCount++
        @trigger('dependency:ready')

      @on 'request', (model, xhr, options) ->
        model.$sending = true

      PushDispatcher.on('chatMessage' , (data) => @add(data))
      PushDispatcher.on('placeAdded'  , (data) => @add(data))
      PushDispatcher.on('placeRemoved', (data) => @add(data))


    initProject: (id, scope) ->
      waitForDependencies = =>
        if @serviceReadyCount == 2
          @fetch({reset: true})
        else
          @once('dependency:ready', waitForDependencies)
      @url = "/api/projects/#{id}/chat_histories"
      waitForDependencies()
      @destroyListenerDeregister = scope.$on('$destroy', => @resetService())


    resetService: ->
      @serviceReadyCount = 0
      @destroyListenerDeregister()
      delete @destroyListenerDeregister
      delete @url
      @reset()
  }
  # END ChatHistories


  return new ChatHistories
]
