###
resolver - User
###
app.factory 'MpUser', ['$q', '$window', '$rootScope', 'Restangular', '$location',
'$route', '$timeout',
($q, $window, $rootScope, Restangular, $location, $route, $timeout) ->

  $users = Restangular.all 'users'

  $users.addRestangularMethod 'login', 'post', 'login'
  $users.addRestangularMethod 'register', 'post', 'register'
  $users.addRestangularMethod 'logout', 'get', 'logout'

  MpUser = {
    $$user: null
    checkLogin: ->
      return if (@$$user && @$$user.fb_access_token && @$$user.id) then true else false
    getId: ->
      return if @$$user then @$$user.id              else undefined
    name: ->
      return if @$$user then @$$user.name            else undefined
    email: ->
      return if @$$user then @$$user.email           else undefined
    fb_user_picture: ->
      return if @$$user then @$$user.fb_user_picture else undefined

    fbLoginCallback: (authResponse, path) ->
      MpUser.$$user =
        fb_access_token: authResponse.accessToken
        fb_user_id:      authResponse.userID

      $timeout -> # force $digest, fix Restangular 1.1.3 not auto resolving bug
        $users.login(MpUser.$$user).then(
          # login to server success
          ((user) ->
            MpUser.$$user = user
            MpUser.pathHandler(path)
            # update user in server
            FB.api '/me', (response) ->
              $rootScope.$apply ->
                MpUser.$$user.name  = response.name
                MpUser.$$user.email = response.email
              MpUser.$$user.put()
            FB.api '/me/picture', (response) ->
              $rootScope.$apply ->
                MpUser.$$user.fb_user_picture = response.data.url
              MpUser.$$user.put()
          ),
          # login to server faild (401 not found), user authorized FB but not
          #   existing in server, in which case user will be registed
          ((response) ->
            FB.api '/me', (response) ->
              MpUser.$$user.name  = response.name
              MpUser.$$user.email = response.email
              # again, force $digest
              $timeout ->
                $users.register(MpUser.$$user).then (user) ->
                  MpUser.$$user = user
                  MpUser.pathHandler(path)
                  # update user in server
                  FB.api '/me/picture', (response) ->
                    $rootScope.$apply ->
                      MpUser.$$user.fb_user_picture = response.data.url
                    MpUser.$$user.put()
          )
        )
    # --- END fbLoginCallback ---

    ###
    handle path callback in fbLoginCallback method
    path object can be a string or function
      if function, result will be used in $location.path() method
      if return value is a promise, then the promise resolve value will
      be used
    ###
    pathHandler: (path) ->
      if path
        if angular.isFunction(path)
          result = path()
          return if !result
          if angular.isString(result)
            $location.path(result)
          else
            result.then (finalPath) ->
              $location.path(finalPath)
        else $location.path(path)

    notLoggedIn: (callback) ->
      MpUser.$$user = null
      $users.logout().then ->
        $location.path '/'
        callback() if callback

    ###
    path    (string|function): a path to redirect to or function return a path
      or promise which resolve into a path string
    error   (function)
    ###
    login: (path, error) ->
      FB.login (response) =>
        if response.authResponse
          @fbLoginCallback(response.authResponse, path)
        else
          @notLoggedIn(error)

    logout: (callback) ->
      [fbLoggedOut, mpLoggedOut] = [$q.defer(), $q.defer()]
      @notLoggedIn -> mpLoggedOut.resolve()
      FB.logout    -> $rootScope.$apply -> fbLoggedOut.resolve()
      $q.all([fbLoggedOut.promise, mpLoggedOut.promise]).then callback
  }

  return MpUser
]
