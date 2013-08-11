app = angular.module 'angular-mp.home.initializer', ['restangular']


# User
app.factory 'User', ['$q', '$window', '$rootScope', 'Restangular', '$location',
'$route',
($q, $window, $rootScope, Restangular, $location, $route) ->

  userReady = $q.defer()

  # # RESTful User
  # Restangular.addElementTransformer 'users', false, (user) ->
  #   # TODO: add addFriend methods
  #   user

  $users = Restangular.all 'users'

  $users.addRestangularMethod 'login', 'post', 'login'
  $users.addRestangularMethod 'register', 'post', 'register'
  $users.addRestangularMethod 'logout', 'get', 'logout'

  # service body
  User =
    $$user: null
    checkLogin: -> return @$$user && @$$user.fb_access_token && @$$user.id
    getId: -> return if @$$user then @$$user.id else undefined
    name: -> return if @$$user then @$$user.name else undefined
    fb_user_picture: -> return if @$$user then @$$user.fb_user_picture else undefined

    # if path is a function, it should return a path to redirect
    login: (path, error) ->
      FB.login (response) -> if response.authResponse then fbLoginCallback(response.authResponse, path) else notLoggedIn(error)

    logout: (callback) ->
      [fbLoggedOut, mpLoggedOut] = [$q.defer(), $q.defer()]
      notLoggedIn -> mpLoggedOut.resolve()
      FB.logout(-> $rootScope.$apply -> fbLoggedOut.resolve())
      $q.all([fbLoggedOut.promise, mpLoggedOut.promise]).then callback


  # callbacks
  fbLoginCallback = (authResponse, path) ->
    User.$$user =
      fb_access_token: authResponse.accessToken
      fb_user_id:      authResponse.userID

    $users.login(User.$$user).then(
      # login success
      ((user) ->
        User.$$user = user
        if path
          if angular.isFunction(path) then $location.path(path()) else $location.path(path)
        userReady.resolve(User)

        # update user in server
        FB.api '/me', (response) ->
          $rootScope.$apply ->
            User.$$user.name  = response.name
            User.$$user.email = response.email
          User.$$user.put()
        FB.api '/me/picture', (response) ->
          $rootScope.$apply ->
            User.$$user.fb_user_picture = response.data.url
          User.$$user.put()
      ),
      # login mp failed, go to register
      ((response) ->
        FB.api '/me', (response) ->
          user =
            name:  response.name
            email: response.email
          $users.register(user).then (user) ->
            User.$$user = user
            if angular.isFunction(path) then $location.path(path()) else $location.path(path)
            userReady.resolve(UserService)

            # update user in server
            FB.api '/me/picture', (response) ->
              $rootScope.$apply ->
                User.$$user.fb_user_picture = response.data.url
              User.$$user.put()
      )
    )

  notLoggedIn = (logoutCallback) ->
    User.$$user = null
    $users.logout().then ->
      $location.path '/'
      userReady.resolve(User)
      logoutCallback() if logoutCallback


  # init
  # ----------------------------------------
  if $window.user.accessToken
    fbLoginCallback $window.user, ->
      if $route.current.$$route.controller == 'OutsideViewCtrl'
        return '/all_projects'
      else return
  else notLoggedIn()


  # Return
  # ----------------------------------------
  return userReady.promise
]
