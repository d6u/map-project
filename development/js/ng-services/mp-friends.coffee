app.service 'MpFriends',
['Restangular','socket','$q','Backbone','$afterLoaded','$afterDumped',
( Restangular,  socket,  $q,  Backbone,  $afterLoaded,  $afterDumped) ->

  # --- Model ---
  Friend = Backbone.Model.extend {

    initialize: ->
  }


  # --- Collection --
  MpFriends = Backbone.Collection.extend {

    # --- Properties ---
    afterLoaded:    $afterLoaded
    afterDumped:    $afterDumped
    $serviceLoaded: false

    onlineIds: []

    model: Friend
    url:  '/api/friendships'
    comparator: (a, b) -> b.get('status') - a.get('status')


    # --- Init ---
    initialize: ->
      @on('service:ready', => @$serviceLoaded = true)
      @on('service:reset', => @$serviceLoaded = false)


    initService: (scope) ->
      @fetch({
        reset: true
        success: =>
          @trigger('service:ready')
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
      @trigger('service:reset')


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
