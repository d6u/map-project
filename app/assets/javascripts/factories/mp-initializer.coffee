###
MpInitializer is in charge of init check of login status and attach REST
  object onto $rootScope.
  The reason I didn't attach REST object in `run` is I want `run` be executed
  before amount everything
###

app.factory 'MpInitializer',
['$rootScope', '$q', 'MpUser', '$window', '$route', 'MpProjects', 'MpChatbox',
( $rootScope,   $q,   MpUser,   $window,   $route,   MpProjects,   MpChatbox) ->

  $rootScope.MpUser     = MpUser
  $rootScope.MpProjects = MpProjects
  $rootScope.MpChatbox  = MpChatbox

  initiation = $q.defer()

  # init
  # ----------------------------------------
  if $window.user.accessToken
    MpUser.fbLoginCallback $window.user, ->
      initiation.resolve()
      if $route.current.$$route.controller == 'OutsideViewCtrl'
        return '/home'
      return
  else
    MpUser.notLoggedIn ->
      initiation.resolve()

  # Return
  # ----------------------------------------
  return initiation.promise
]