###
resolver - User
###
app.factory 'MpUser', ['$q', '$window', '$rootScope', 'Restangular', '$location',
'$route',
($q, $window, $rootScope, Restangular, $location, $route) ->

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

    fbLoginCallback: (authResponse, path, callback) ->
      MpUser.$$user =
        fb_access_token: authResponse.accessToken
        fb_user_id:      authResponse.userID

      $users.login(MpUser.$$user).then(
        # login to server success
        ((user) ->
          MpUser.$$user = user
          if path
            if angular.isFunction(path) then $location.path(path()) else $location.path(path)
          callback() if callback

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
            $users.register(MpUser.$$user).then (user) ->
              MpUser.$$user = user
              if angular.isFunction(path) then $location.path(path()) else $location.path(path)
              callback() if callback

              # update user in server
              FB.api '/me/picture', (response) ->
                $rootScope.$apply ->
                  MpUser.$$user.fb_user_picture = response.data.url
                MpUser.$$user.put()
        )
      )
    # --- END fbLoginCallback ---

    notLoggedIn: (callback) ->
      MpUser.$$user = null
      $users.logout().then ->
        $location.path '/'
        callback() if callback

    ###
    path    (string|function): a path to redirect to or function return a path
    success (function)
    error   (function)
    ###
    login: (path, success, error) ->
      FB.login (response) ->
        if response.authResponse
          fbLoginCallback(response.authResponse, path, success)
        else notLoggedIn(error)

    logout: (callback) ->
      [fbLoggedOut, mpLoggedOut] = [$q.defer(), $q.defer()]
      @notLoggedIn -> mpLoggedOut.resolve()
      FB.logout    -> $rootScope.$apply -> fbLoggedOut.resolve()
      $q.all([fbLoggedOut.promise, mpLoggedOut.promise]).then callback
  }

  return MpUser
]
