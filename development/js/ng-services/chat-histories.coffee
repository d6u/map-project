app.factory 'ChatHistories',
['socket','MpUser','ParticipatingUsers','Backbone','MapPlaces','$q',
( socket,  MpUser,  ParticipatingUsers,  Backbone,  MapPlaces,  $q) ->


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

    initialize: () ->
      @on 'request', (model, xhr, options) ->
        model.$sending = true

      socket.on 'chatData', (data) =>
        @add(data)


    initProject: (id, scope) ->
      @url = "/api/projects/#{id}/chat_histories"

      placesLoaded  = $q.defer()
      friendsLoaded = $q.defer()
      MapPlaces.afterLoaded(=> placesLoaded.resolve())
      ParticipatingUsers.afterLoaded(=> friendsLoaded.resolve())
      $q.all([placesLoaded.promise, friendsLoaded.promise])
        .then(=> @fetch({reset: true}))

      @destroyListenerDeregister = scope.$on('$destroy', => @resetService())


    resetService: ->
      @destroyListenerDeregister()
      delete @destroyListenerDeregister
      delete @url
      @reset()
  }
  # END ChatHistories


  return new ChatHistories
]
