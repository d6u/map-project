app.factory 'ParticipatingUsers',
['$http','Backbone',
( $http,  Backbone) ->

  # --- Model ---
  User = Backbone.Model.extend()


  # --- Collection ---
  ParticipatingUsers = Backbone.Collection.extend {

    # --- Properties ---
    model: User


    # --- Init ---
    initialize: ->
      @on 'remove', (user) =>
        $http.delete("/api/projects/#{@project_id}/remove_users", {params: {user_ids: user.id}})


    initProject: (id, scope) ->
      @project_id = id
      @url        = "/api/projects/#{@project_id}/participating_users"
      @fetch({
        reset: true
        success: =>
          @enter('service:ready')
      })
      @destroyListenerDeregister = scope.$on('$destroy', => @resetService())


    resetService: ->
      @destroyListenerDeregister()
      delete @destroyListenerDeregister
      @reset()
      delete @url
      delete @project_id
      @leave('service:ready')
  }
  # END ParticipatingUsers


  return new ParticipatingUsers
]
