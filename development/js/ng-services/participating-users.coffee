app.factory 'ParticipatingUsers', [->

  # --- Model ---
  ParticipatingUser = Backbone.Model.extend {
    initialize: ->
      console.debug arguments
  }


  # --- Collection ---
  ParticipatingUsers = Backbone.Collection.extend {

    model: ParticipatingUser

    initialize: ->

    loadProject: (scope, projectId) ->
      @url = "/api/projects/#{projectId}/participating_users"
  }


  return new ParticipatingUsers
]
