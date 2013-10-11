app.factory 'ParticipatingUsers', [->

  # --- Model ---
  ParticipatingUser = Backbone.Model.extend {}


  # --- Collection ---
  ParticipatingUsers = Backbone.Collection.extend {

    model: ParticipatingUser

    loadProject: (scope, projectId) ->
      @url = "/api/projects/#{projectId}/participating_users"
  }


  return new ParticipatingUsers
]
