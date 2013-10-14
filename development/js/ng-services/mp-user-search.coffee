app.factory 'MpUserSearch',
['Backbone',
( Backbone)->

  # --- Model ---
  User = Backbone.Model.extend {
    initialize: ->
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
