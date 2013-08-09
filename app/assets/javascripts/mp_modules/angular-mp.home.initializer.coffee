app = angular.module 'angular-mp.home.initializer', ['restangular']


# User
app.factory 'User', ['$q', '$window', '$rootScope', 'Restangular',
($q, $window, $rootScope, Restangular) ->

  userReady = $q.defer()

  # RESTful User
  Restangular.addElementTransformer 'users', false, (user) ->
    # TODO: add addFriend methods
    user

  User = Restangular.all 'users'

  User.addRestangularMethod 'login', 'post', 'login'
  User.addRestangularMethod 'register', 'post', 'register'
  User.addRestangularMethod 'logout', 'get', 'logout'

  # service body
  UserService =
    $$User: User
    $$user: {}

    login: (success, error) ->
      FB.login (response) ->
        if response.authResponse
          loggedIn(response.authResponse, success)
        else
          notLoggedIn(error)

    logout: (logoutCallback) ->
      fbLoggedOut = $q.defer()
      mpLoggedOut = $q.defer()

      FB.logout -> $rootScope.$apply -> fbLoggedOut.resolve()
      notLoggedIn -> mpLoggedOut.resolve()

      $q.all([fbLoggedOut.promise, mpLoggedOut.promise]).then ->
        logoutCallback()

    fb_access_token: -> UserService.$$user.fb_access_token
    fb_user_id: -> UserService.$$user.fb_user_id

    checkLogin: ->
      if @fb_access_token() && @$$user.id then true else false


  # callbacks
  loggedIn = (authResponse, loginCallback) ->

    if authResponse
      user.fb_access_token = authResponse.accessToken
      user.fb_user_id      = authResponse.userID

    User.login(user).then ((user) ->

      # login success
      UserService.$$user = user
      userReady.resolve(UserService)
      loginCallback() if loginCallback

      FB.api '/me', (response) ->
        UserService.$$user.name      = response.name
        UserService.$$user.email     = response.email
        $rootScope.$apply()
        UserService.$$user.put()

      FB.api '/me/picture', (response) ->
        UserService.$$user.fb_user_picture   = response.data.url
        $rootScope.$apply()
        UserService.$$user.put()

    ), ((response) ->

      # login mp failed, go to register
      FB.api '/me', (response) ->
        user.name      = response.name
        user.email     = response.email
        $rootScope.$apply()

        User.post(user).then (user) ->
          UserService.$$user = user
          userReady.resolve(UserService)
          loginCallback() if loginCallback

          FB.api '/me/picture', (response) ->
            UserService.$$user.fb_user_picture   = response.data.url
            $rootScope.$apply()
            UserService.$$user.put()
    )

  notLoggedIn = (logoutCallback) ->
    UserService.$$user = {}
    User.logout().then ->
      userReady.resolve(UserService)
      logoutCallback() if logoutCallback

  # check fb login status
  if $window.user.accessToken
    loggedIn($window.user)
  else
    notLoggedIn()

  # Return
  return userReady.promise
]
