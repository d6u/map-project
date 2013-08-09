app = angular.module 'angular-mp.api', ['restangular']


# Project
app.factory 'Project', ['Restangular', (Restangular) ->

  Restangular.addElementTransformer 'projects', false, (project) ->
    # TODO
    # project.addRestangularMethod 'addParticipatedUser', 'post', 'add_participated_user'
    project


  Project = Restangular.all 'projects'

  Project.addRestangularMethod 'find_by_title', 'get', '', {title: 'last unsaved project'}

  # return
  Project
]


# ActiveProject
app.factory 'ActiveProject', ['Project', (Project) ->

  ProjectService =
    $$Project: Project
    project: {}
    places: []
    partcipatedUsers: []
    roomClientIds: []
    reset: ->
      @project = {}
      @places = []
      @partcipatedUsers = []
      @roomClientIds = []

  return ProjectService
]


# friendships
app.factory 'Friendship', ['Restangular', (Restangular) ->

  Restangular.all 'friendships'
]


# invitations
app.factory 'Invitation', ['$http', ($http) ->

  generate: (project_id)->
    postBody =
      invitation: {project_id: project_id}
    $http.post('/invitation/generate', postBody).then (response) -> response.data.code
]
