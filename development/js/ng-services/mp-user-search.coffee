app.factory 'MpUserSearch',
['Backbone','$http',
( Backbone,  $http)->

  # --- Model ---
  User = Backbone.Model.extend {

    addAsFriend: ->
      @set({pending: true, added: true})
      $http.post("/api/friendships", {friendship: {friend_id: @id}})
  }


  # --- Collection ---
  MpUserSearch = Backbone.Collection.extend {

    model: User

    url: ->
      return "/api/users?name=#{@_keyword}"

    initialize: ->

    searchUserByName: (name) ->
      @_keyword = name
      @fetch({reset: true})
  }
  # END MpUserSearch


  return new MpUserSearch
]
