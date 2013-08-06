app = angular.module 'angular-facebook', []


app.provider 'FB', class
  # config
  init: (options) -> FB.init options

  # factory
  $get: ['$rootScope', '$timeout', '$q', 'User',
  ($rootScope, $timeout, $q, User) ->

    loginChecked = $q.defer()

    FB.doLogin = (success, error) ->
      FB.login (response) ->
        if response.authResponse
          loggedIn(response.authResponse, success)
        else
          notLoggedIn(error)

    FB.doLogout = (logoutCallback) ->
      fbLoggedOut = $q.defer()
      mpLoggedOut = $q.defer()

      FB.logout -> $rootScope.$apply -> fbLoggedOut.resolve()
      notLoggedIn -> mpLoggedOut.resolve()

      $q.all([fbLoggedOut.promise, mpLoggedOut.promise]).then ->
        logoutCallback()

    # check fb login status
    FB.getLoginStatus (response) ->
      switch response.status
        when 'connected'
          loggedIn(response.authResponse)
        else
          notLoggedIn()

    # callbacks
    loggedIn = (authResponse, loginCallback) ->
      $rootScope.user.fb_access_token = authResponse.accessToken
      $rootScope.user.fb_user_id      = authResponse.userID

      User.login($rootScope.user)
      .then ((user) ->

        # login success
        $rootScope.user = user
        loginChecked.resolve(FB)
        loginCallback() if loginCallback

        FB.api '/me', (response) ->
          $rootScope.user.name      = response.name
          $rootScope.user.email     = response.email
          $rootScope.$apply()
          user.put()

        FB.api '/me/picture', (response) ->
          $rootScope.user.fb_user_picture   = response.data.url
          $rootScope.$apply()
          user.put()

      ), ((response) ->

        # login mp failed, go to register
        FB.api '/me', (response) ->
          $rootScope.user.name      = response.name
          $rootScope.user.email     = response.email
          $rootScope.$apply()

          User.post($rootScope.user).then (user) ->
            $rootScope.user = user
            loginChecked.resolve(FB)
            loginCallback() if loginCallback

            FB.api '/me/picture', (response) ->
              $rootScope.user.fb_user_picture   = response.data.url
              $rootScope.$apply()
              user.put()
      )

    notLoggedIn = (logoutCallback) ->
      $rootScope.user = {}
      User.logout().then ->
        loginChecked.resolve(FB)
        logoutCallback() if logoutCallback

    # return
    return loginChecked.promise
  ]
