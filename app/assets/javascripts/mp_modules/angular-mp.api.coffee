app = angular.module 'angular-mp.api', ['ngResource']


# User
app.factory 'User', ['$http', '$resource', ($http, $resource) ->

  userResource = $resource('/users/:id', {id: '@id'}, {
    save: {method: 'PUT'}
  })

  userResource.login = (user) ->
    # fb_access_token, fb_user_id
    $http.post('/login', {user: user})
    .then ((response) -> response.data), (-> false)
    # .then ((response) -> response.data ), (-> false)

  userResource.register = (user) ->
    # fb_access_token, fb_user_id, email, name
    $http.post('/register', {user: user}).then (response) -> response.data

  userResource.logout = -> $http.get('/logout')

  # return
  userResource
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
