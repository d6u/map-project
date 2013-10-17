app.factory 'ParticipatingUsers', ['$http', ($http) ->

  # --- Model ---
  User = Backbone.Model.extend {

  }


  # --- Collection ---
  ParticipatingUsers = Backbone.Collection.extend {

    model: User

    initialize: ->
      @on 'remove', (user) =>
        $http.delete("/api/projects/#{@project_id}/remove_users", {params: {user_ids: user.id}})


    initProject: (id, scope) ->
      @project_id = id
      @url = "/api/projects/#{id}/participating_users"
      @fetch({reset: true})

      scope.$on '$destroy', =>
        @reset()
  }
  # END ParticipatingUsers


  return new ParticipatingUsers
]
