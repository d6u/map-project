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

    initialize: ->



    initService: (scope) ->
      @fetch({reset: true})

      deregister = scope.$on '$destroy', =>
        @reset()
        deregister()
  }
  # END MpFriends


  return new MpFriends
]
