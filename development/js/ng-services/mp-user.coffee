app.factory 'MpUser',
['$q','$rootScope','$http','$window',
( $q,  $rootScope,  $http,  $window) ->

  fbLoginChecked = $q.when($window.facebookLoginChecked)


  class User
    constructor: (@attributes) ->
      @get = (attrName) ->
        return @attributes[attrName]


  # --- MpUser ---
  class MpUser
    constructor: ->
      # --- Local API ---
      @getLoginStatus = (emailCallback, fbCallback, outCallback) ->
        $http.get('/api/auth/login_status')
        .then(
          ((response) =>
            if response.status == 200
              if response.data.type == 'facebook'
                fbCallback() if fbCallback?
              else
                @$$processLoginSuccessData(response.data, emailCallback)
          ),
          ((response) ->
            if response.status == 404
              outCallback() if outCallback?
          )
        )


      # --- Facebook ---
      @fbRegister = (success, error) ->
        fbLoginChecked.then (response) =>
          if response.authResponse?
            @$$fbLoginSuccess(response.authResponse, success)
          else
            @$$invokeFbLogin(success, error)


      @fbLogin = -> @fbRegister.apply(@, arguments)


      @fbRememberLogin = (success, error) ->
        fbLoginChecked.then (response) =>
          if !response.authResponse?
            error() if error?
          else
            $http.post('/api/auth/fb_remember_login', {
              user:
                fb_access_token: response.authResponse.accessToken
                fb_user_id:      response.authResponse.userID
            })
            .then(
              ((response) => # success
                if response.status == 200
                  @$$processLoginSuccessData(response.data, success)
              ),
              ((response) -> # failed
                if response.status == 406
                  error() if error?
              )
            )


      # --- Email ---
      @emailLogin = (user, success, fail) ->
        $http.post('/api/auth/email_login', {user: user}).then ((response) =>
          if response.status == 200
            @$$processLoginSuccessData(response.data, success)
        ), (response) ->
          if response.status == 406
            fail(response.data) if fail?


      @emailRegister = (user, success, fail) ->
        $http.post('/api/auth/email_register', {user: user}).then ((response) =>
          if response.status == 200
            @$$processLoginSuccessData(response.data, success)
        ), (response) ->
          if response.status == 406
            fail(response.data) if fail?


      # --- Logout ---
      @logout = (success) ->
        $http.get('/api/auth/logout').then =>
          delete @$$user
          delete @$$access_token
          success() if success?


      # --- Getters ---
      @getUser = ->
        return @$$user
      @getId = ->
        return @$$user?.get('id')
      @getName = ->
        return @$$user?.get('name')
      @getEmail = ->
        return @$$user?.get('email')
      @getProfilePicture = ->
        return @$$user?.get('profile_picture')

    # END constructor


    $$fbLoginSuccess: (authResponse, callback) ->
      fbUser = {
        fb_access_token: authResponse.accessToken
        fb_user_id:      authResponse.userID
      }

      $http.post('/api/auth/fb_login', {user: fbUser})
      .then(
        # login to server success
        ((response) =>
          if response.status == 200
            @$$processLoginSuccessData(response.data, callback)
        ),
        # login to server faild (406 not acceptable)
        #   user authorized FB but does not exist in server, in this case user
        #   will be registered with server
        ((response) =>
          FB.api '/me?fields=name,email,picture', (response) =>
            fbUser.name  = response.name
            fbUser.email = response.email
            fbUser.profile_picture = response.picture.data.url
            $rootScope.$apply =>
              $http.post('/api/auth/fb_register', {user: fbUser})
              .then (response) =>
                if response.status == 200
                  @$$processLoginSuccessData(response.data, callback)
        )
      )
    # END $$fbLoginSuccess


    $$invokeFbLogin: (success, error) ->
      FB.login (response) =>
        $rootScope.$apply =>
          if response.authResponse?
            @$$fbLoginSuccess(response.authResponse, success)
          else if error?
            error()


    $$processLoginSuccessData: (data, done) ->
      if data.user?
        @$$user = new User(data.user)
        @$$fbExchangeAccessTokenWithCode(data.code) if data.code?
      else
        @$$user = new User(data)
      done() if done?


    # TODO: the offical FB API has problems to exchange token
    $$fbExchangeAccessTokenWithCode: (code) ->
      @$$access_token = code

      # FB.api '/oauth/authorize', {
      #   client_id:    $window.fbCLientId
      #   code:         code
      #   redirect_uri: $window.fbRedirectUrl
      #   machine_id:   @$$machine_id
      # }, (response) ->
      #   console.debug response


  return new MpUser
]
