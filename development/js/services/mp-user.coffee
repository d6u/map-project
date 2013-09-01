###
MpUser

--- API ---
.login(path[, success][, error])
  path:    can be a string or function. If function, result will be used in
           $location.path(). If return value is a promise, then the promise
           resolve value will be used for redirection
  success: function will be called before redirection, if path is a function,
           success will be called before path.
  error:   called when login failed

  success and error can be null

.logout([path][, success])
  path:    same as login method, besides, if null will rediction to '/'
  success: same as login

--- Low level helper ---
.fbLoginCallback(authResponse, path, callback)
  login call this method after checking with facebook

  authResponse: same as facebook's authResponse
  path:         passed from login method
  callback:     login method pass success function to this method

.fbLogoutCallback(path, callback)
  logout call this method after logging out FB and server

  path:     passed from logout method
  callback: logout method pass success function to this method
###
app.factory 'MpUser',
['$q','$rootScope','Restangular','$location','$route','$timeout',
( $q,  $rootScope,  Restangular,  $location,  $route,  $timeout) ->

  $users = Restangular.all 'users'

  $users.addRestangularMethod 'login'   , 'post', 'login'
  $users.addRestangularMethod 'register', 'post', 'register'
  $users.addRestangularMethod 'logout'  , 'get' , 'logout'

  MpUser = {
    $$user: {}
    login: (path, success, error) ->
      FB.login (response) =>
        $rootScope.$apply =>
          if response.authResponse then @fbLoginCallback(response.authResponse, path, success) else @fbLogoutCallback(null, error)

    logout: (path, success) ->
      [fbLoggedOut, mpLoggedOut] = [$q.defer(), $q.defer()]

      FB.logout -> $rootScope.$apply -> fbLoggedOut.resolve()
      path = '/' if !path
      @fbLogoutCallback path, -> mpLoggedOut.resolve()

      $q.all([fbLoggedOut.promise, mpLoggedOut.promise]).then(success)

    fbLoginCallback: (authResponse, path, callback) ->
      fbUser = {
        fb_access_token: authResponse.accessToken
        fb_user_id:      authResponse.userID
      }

      $users.login(fbUser).then ((user) ->
        # login to server success
        MpUser.$$user = user
        # callbacks
        callback() if callback
        MpUser.pathHandler(path) if path
        # update user in server
        FB.api '/me?fields=name,email,picture', (response) ->
          $rootScope.$apply ->
            MpUser.$$user.name            = response.name
            MpUser.$$user.email           = response.email
            MpUser.$$user.fb_user_picture = response.picture.data.url
            MpUser.$$user.put()
      ), (response) ->
        # login to server faild (401 not found), user authorized FB but not
        #   existing in server, in this case user will registe first
        FB.api '/me?fields=name,email,picture', (response) ->
          fbUser.name            = response.name
          fbUser.email           = response.email
          fbUser.fb_user_picture = response.picture.data.url
          # force $digest
          $rootScope.$apply ->
            $users.register(fbUser).then (user) ->
              MpUser.$$user = user
              callback() if callback
              MpUser.pathHandler(path) if path
    # --- END fbLoginCallback ---

    fbLogoutCallback: (path, callback) ->
      MpUser.$$user = {}
      $users.logout().then ->
        callback() if callback
        MpUser.pathHandler(path) if path

    ###
    handle path callback in fbLoginCallback method
    path object can be a string or function
      if function, result will be used in $location.path() method
      if return value is a promise, then the promise resolve value will
      be used
    ###
    pathHandler: (path) ->
      # path is function
      if angular.isFunction(path)
        result = path()
        throw new Error('path function returns nothing') if !result
        if angular.isString(result)
          $location.path(result)
        else
          result.then (finalPath) ->
            $location.path(finalPath)
      # path is string
      else
        $location.path(path)


    # Getters
    checkLogin: ->
      return if (@$$user.fb_access_token && @$$user.id) then true else false
    getId: ->
      return @$$user.id
    name: ->
      return @$$user.name
    email: ->
      return @$$user.email
    fb_user_picture: ->
      return @$$user.fb_user_picture
    getUser: ->
      if @checkLogin()
        return {
          id:              @getId()
          name:            @name()
          fb_user_picture: @fb_user_picture()
        }
      else
        return null
  } # --- END MpUser ---

  # Return
  return MpUser
]
