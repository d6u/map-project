app.factory 'ParticipatingUsers', [->

  # --- Model ---
  User = Backbone.Model.extend {

  }


  # --- Collection ---
  ParticipatingUsers = Backbone.Collection.extend {

    model: User

    initialize: () ->

    initProject: (id, scope) ->
      @$scope = scope
      @url    = "/api/projects/#{id}/participating_users"
      @fetch({reset: true})

      @$scope.$on '$destroy', =>
        delete @$scope
        @reset()
  }


  return new ParticipatingUsers
]
