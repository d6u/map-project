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

    FB.doLogout = (success) ->
      FB.logout ->
        notLoggedIn(success)

    # check fb login status
    FB.getLoginStatus (response) ->
      switch response.status
        when 'connected'
          loggedIn(response.authResponse)
        else
          notLoggedIn()

    loggedIn = (authResponse, loginCallback) ->
      $rootScope.user.fb_access_token = authResponse.accessToken
      $rootScope.user.fb_user_id      = authResponse.userID
      User.login($rootScope.user).then (user) ->
        if user
          $timeout -> loginChecked.resolve(FB)
          $rootScope.user.id = user.id
          loginCallback() if loginCallback
          FB.api '/me', (response) ->
            $rootScope.user.name      = response.name
            $rootScope.user.email     = response.email
            $rootScope.$apply()
            User.save($rootScope.user)
          FB.api '/me/picture', (response) ->
            $rootScope.user.picture   = response.data.url
            $rootScope.$apply()
        else
          FB.api '/me', (response) ->
            $rootScope.user.name      = response.name
            $rootScope.user.email     = response.email
            $rootScope.$apply()
            User.register $rootScope.user, (user) ->
              $timeout -> loginChecked.resolve(FB)
              $rootScope.user.id = user.id
              loginCallback() if loginCallback

    notLoggedIn = (logoutCallback) ->
      $rootScope.user = {}
      User.logout().then ->
        loginChecked.resolve(FB)
        logoutCallback() if logoutCallback

    return loginChecked.promise
  ]
