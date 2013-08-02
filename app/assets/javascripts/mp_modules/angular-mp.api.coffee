app = angular.module 'angular-mp.api', ['ngResource']


# User
app.factory 'User', ['$http', ($http) ->

  login: (user) ->
    # fb_access_token, fb_user_id
    $http.post('/login', {user: user}).then (response) ->
      return false if response.status != 200
      return response.data

  register: (user) ->
    # fb_access_token, fb_user_id, email, name
    $http.post('/register', {user: user}).then (response) -> response.data

  logout: -> $http.get('/logout')
]


# Project
app.factory 'Project', ['$resource', ($resource) ->
  $resource('/projects')
]


# Place
app.factory 'Place', ['$resource', ($resource) ->
  $resource('/places')
]
