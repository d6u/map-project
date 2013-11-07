app.service 'MpFriends',
['socket','$q','Backbone',
( socket,  $q,  Backbone) ->

  # --- Model ---
  Friend = Backbone.Model.extend()


  # --- Collection --
  MpFriends = Backbone.Collection.extend {

    # --- Properties ---
    onlineIds: []

    model: Friend
    url:  '/api/friendships'
    comparator: (a, b) -> b.get('status') - a.get('status')


    # --- Init ---
    initialize: ->


    initService: (scope) ->
      @fetch({
        reset: true
        success: =>
          @enter('service:ready')
      })

      socket.on 'friendsOnlineIds', (ids) =>
        @onlineIds = ids
        @updateFriendsOnlineStatus()

      # listen to on/off line event in collection instread of model to reduce
      #   digest cycle
      socket.on 'friendGoOnline', (id) =>
        @onlineIds = _.union(@onlineIds, [id])
        @updateFriendsOnlineStatus()

      socket.on 'friendGoOffline', (id) =>
        @onlineIds = _.without(@onlineIds, id)
        @updateFriendsOnlineStatus()

      @on('all', @updateFriendsOnlineStatus, @)
      @destroyListenerDeregister = scope.$on('$destroy', => @resetService())


    resetService: ->
      @destroyListenerDeregister()
      delete @destroyListenerDeregister
      socket.removeAllListeners('friendGoOffline')
      socket.removeAllListeners('friendGoOnline')
      socket.removeAllListeners('friendsOnlineIds')
      @off('all', @updateFriendsOnlineStatus, @)
      @onlineIds = []
      @reset()
      @leave('service:ready')


    # --- Custom Methods ---
    updateFriendsOnlineStatus: ->
      @forEach (friend) =>
        if _.indexOf(@onlineIds, friend.id) > -1
          friend.online = true
        else
          delete friend.online if friend.online?
  }
  # END MpFriends


  return new MpFriends
]
