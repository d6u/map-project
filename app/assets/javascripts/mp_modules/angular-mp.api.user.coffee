angular.module('angular-mp.api.user', ['ngResource'])

.factory('User', [
  '$resource', '$http',
  ($resource, $http) ->

    login: (user) ->
      # email, fb_access_token, fb_user_id
      $http.post('/login', {user: user}).then (response) ->
        return false if response.status != 200
        return response.data
])
