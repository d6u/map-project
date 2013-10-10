app.factory 'MpUser',
['$q','$rootScope','$http','$window',
( $q,  $rootScope,  $http,  $window) ->


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
    emailLogin: (user, success, fail) ->
      $http.post('/api/auth/email_login', {user: user}).then ((response) =>
        if response.status == 200
          @$$user = response.data
          success() if success
      ), (response) ->
        if response.status == 406
          fail(response.data) if fail

    emailRegister: (user, success, fail) ->
      $http.post('/api/auth/email_register', {user: user}).then ((response) =>
        if response.status == 200
          @$$user = response.data
          success() if success
      ), (response) ->
        if response.status == 406
          fail(response.data) if fail

    # --- Logout ---
    logout: (success) ->
      $http.get('/api/auth/logout').then =>
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
