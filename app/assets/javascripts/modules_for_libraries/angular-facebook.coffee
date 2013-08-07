app = angular.module 'angular-facebook', ['angular-mp.api']


# FB
app.factory 'FB', ['$window', '$rootScope', '$timeout', '$q', 'User',
($window, $rootScope, $timeout, $q, User) ->

  $rootScope.user = $window.user

  loginChecked = $q.defer()

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
  if $rootScope.user.fb_access_token
    loggedIn({
      accessToken: $rootScope.user.fb_access_token
      userID:      $rootScope.user.fb_user_id
      })
  else
    notLoggedIn()

  # return
  return loginChecked.promise
]
