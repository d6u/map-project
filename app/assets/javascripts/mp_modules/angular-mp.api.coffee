app = angular.module 'angular-mp.api', ['ngResource']


# User
app.factory 'User', ['Restangular', (Restangular) ->

  # Restangular.addElementTransformer 'users', true, (users) ->
    # users.addRestangularMethod

  User = Restangular.all 'users'

  User.addRestangularMethod 'login', 'post', 'login'
  User.addRestangularMethod 'register', 'post', 'register'
  User.addRestangularMethod 'logout', 'get', 'logout'

  # return
  User
]


# Project
app.factory 'Project', ['$resource', ($resource) ->
  $resource('/projects/:project_id', {project_id: '@id'}, {
    create:
      method: 'POST'
    update:
      method: 'PUT'
    find_by_title:
      method: 'GET'
  })
]


# Place
app.factory 'Place', ['$resource', ($resource) ->
  $resource('/projects/:project_id/places/:place_id',
    {project_id: '@project_id', place_id: '@id'},
    {
      create:
        method: 'POST'
      update:
        method: 'PUT'
    }
  )
]


# friendships
app.factory 'Friendship', ['Restangular', (Restangular) ->

  Restangular.all('friendships')
]
