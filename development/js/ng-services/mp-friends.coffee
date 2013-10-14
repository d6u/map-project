app.service 'MpFriends',
['Restangular','socket','$q','Backbone',
( Restangular,  socket,  $q,  Backbone) ->

  # --- Model ---
  Friend = Backbone.Model.extend {

    initialize: ->
  }


  # --- Collection --
  MpFriends = Backbone.Collection.extend {

    model: Friend
    url: "/api/friends"

    onlineIds: []


    initialize: ->


    initService: (scope) ->
      @fetch({reset: true})

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


      @on 'all', @updateFriendsOnlineStatus, @

      # --- clean up ---
      deregister = scope.$on '$destroy', =>
        deregister()
        @off 'all', @updateFriendsOnlineStatus, @
        socket.removeAllListeners('friendGoOffline')
        socket.removeAllListeners('friendGoOnline')
        socket.removeAllListeners('friendsOnlineIds')
        @reset()


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
