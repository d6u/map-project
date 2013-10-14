app.factory 'ParticipatingUsers', [->

  # --- Model ---
  User = Backbone.Model.extend {

  }


  # --- Collection ---
  ParticipatingUsers = Backbone.Collection.extend {

    model: User

    initialize: () ->

    initProject: (id, scope) ->
      @url = "/api/projects/#{id}/participating_users"
      @fetch({reset: true})

      scope.$on '$destroy', =>
        @reset()
  }
  # END ParticipatingUsers


  return new ParticipatingUsers
]
