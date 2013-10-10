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
['$q','$rootScope','Restangular','$location','$timeout','$http','$window',
( $q,  $rootScope,  Restangular,  $location,  $timeout,  $http,  $window) ->

  $users = Restangular.all 'users'

  $users.addRestangularMethod 'login_status'  , 'get' , 'login_status'
  $users.addRestangularMethod 'fb_login'      , 'post', 'fb_login'
  $users.addRestangularMethod 'fb_register'   , 'post', 'fb_register'
  $users.addRestangularMethod 'email_login'   , 'post', 'email_login'
  $users.addRestangularMethod 'email_register', 'post', 'email_register'
  $users.addRestangularMethod 'logout'        , 'get' , 'logout'


  # --- MpUser ---
  MpUser = {
    # --- Facebook ---
    fbRegister: (success, error) ->
      $q.when($window.facebookLoginChecked).then (response) =>
        if response.authResponse?
          @$$fbLoginSuccess(response.authResponse, success)
        else
          FB.login (response) =>
            $rootScope.$apply =>
              if response.authResponse?
                @$$fbLoginSuccess(response.authResponse, success)
              else
                error() if error


    fbLogin: -> @fbRegister.apply(@, arguments)


    fbRememberLogin: (success, error) ->
      $q.when($window.facebookLoginChecked).then (response) =>
        if response.authResponse?
          $http.post('/api/auth/fb_remember_login', {
            user:
              fb_access_token: response.authResponse.accessToken
              fb_user_id:      response.authResponse.userID
          }).then ((response) =>
            if response.status == 200
              @$$user = response.data.user
              @$$fbExchangeAccessTokenWithCode(response.data.code)
              success() if success
          ), (response) ->
            if response.status == 406
              error() if error
        else
          error() if error


    # --- Email ---
    emailLogin: (user, success) ->
      $users.email_login(user).then (user) =>
        @$$user = user
        success() if success

    emailRegister: (user, success) ->
      $users.email_register(user).then (user) =>
        @$$user = user
        success() if success

    # --- Logout ---
    logout: (success) ->
      $users.logout().then =>
        @$$user = null
        success() if success


    # --- Getters ---
    getUser: ->
      if @$$user then {id: @getId(), name: @getName(), profile_picture: @getProfilePicture()} else null
    getId: ->
      if @$$user then @$$user.id else null
    getName: ->
      if @$$user then @$$user.name else null
    getEmail: ->
      if @$$user then @$$user.email else null
    getProfilePicture: ->
      if @$$user then @$$user.profile_picture else null


    # --- Low Level API ---
    # property
    $$user: null

    # facebook
    $$fbLoginSuccess: (authResponse, callback) ->
      fbUser = {
        fb_access_token: authResponse.accessToken
        fb_user_id:      authResponse.userID
      }

      $http.post('/api/auth/fb_login', {user: fbUser}).then ((response) =>
        # login to server success
        if response.status == 200
          @$$user = response.data.user
          @$$fbExchangeAccessTokenWithCode(response.data.code)
          callback() if callback
      ), (response) =>
        # login to server faild (406 not acceptable)
        #   user authorized FB but does not exist in server, in this case user
        #   will be registered with server
        FB.api '/me?fields=name,email,picture', (response) =>
          fbUser.name            = response.name
          fbUser.email           = response.email
          fbUser.profile_picture = response.picture.data.url
          $rootScope.$apply =>
            $http.post('/api/auth/fb_register', {user: fbUser}).then (response) =>
              if response.status == 200
                @$$user = response.data.user
                @$$fbExchangeAccessTokenWithCode(response.data.code)
                callback() if callback
    # END $$fbLoginSuccess


    $$fbExchangeAccessTokenWithCode: (code) ->
      @$$access_token = code

      # TODO: the offical FB API has problems to exchange token

      # FB.api '/oauth/authorize', {
      #   client_id:    $window.fbCLientId
      #   code:         code
      #   redirect_uri: $window.fbRedirectUrl
      #   machine_id:   @$$machine_id
      # }, (response) ->
      #   console.debug response


    # initialize
    $$getLoginStatus: (emailLoginCallback, fbLoginCallback, notLoginCallback) ->
      $http.get('/api/auth/login_status').then ((response) =>
        if response.status == 200
          if response.data.type == 'facebook'
            fbLoginCallback(response.data)
          else
            @$$user = response.data
            emailLoginCallback(response.data)
      ), (response) ->
        if response.status == 404
          notLoginCallback(response)
  }


  # Return
  return MpUser
]
