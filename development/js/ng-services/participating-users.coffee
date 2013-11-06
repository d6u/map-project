app.factory 'ParticipatingUsers',
['$http','$afterLoaded','$afterDumped',
( $http,  $afterLoaded,  $afterDumped) ->

  # --- Model ---
  User = Backbone.Model.extend()


  # --- Collection ---
  ParticipatingUsers = Backbone.Collection.extend {

    # --- Properties ---
    afterLoaded:    $afterLoaded
    afterDumped:    $afterDumped
    $serviceLoaded: false

    model: User


    # --- Init ---
    initialize: ->
      @on('service:ready', => @$serviceLoaded = true)
      @on('service:reset', => @$serviceLoaded = false)
      @on 'remove', (user) =>
        $http.delete("/api/projects/#{@project_id}/remove_users", {params: {user_ids: user.id}})


    initProject: (id, scope) ->
      @project_id = id
      @url        = "/api/projects/#{@project_id}/participating_users"
      @fetch({
        reset: true
        success: =>
          @trigger('service:ready')
      })
      @destroyListenerDeregister = scope.$on('$destroy', => @resetService())


    resetService: ->
      @destroyListenerDeregister()
      delete @destroyListenerDeregister
      @reset()
      delete @url
      delete @project_id
      @trigger('service:reset')
  }
  # END ParticipatingUsers


  return new ParticipatingUsers
]
