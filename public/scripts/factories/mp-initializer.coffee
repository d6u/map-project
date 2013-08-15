###
MpInitializer is in charge of init check of login status and attach REST
  object onto $rootScope.
  The reason I didn't attach REST object in `run` is I want `run` be executed
  before amount everything
###

app.factory 'MpInitializer', ['$q', 'MpUser', '$window', '$rootScope',
'MpProjects', 'MpChatbox', 'TheMap',
($q, MpUser, $window, $rootScope, MpProjects, MpChatbox, TheMap) ->

  $rootScope.MpUser     = MpUser
  $rootScope.MpProjects = MpProjects
  $rootScope.MpChatbox  = MpChatbox
  $rootScope.TheMap     = TheMap

  initiation = $q.defer()

  # init
  # ----------------------------------------
  if $window.user.accessToken
    MpUser.fbLoginCallback($window.user,
      (->
        return '/all_projects' if $route.current.$$route.controller == 'OutsideViewCtrl'
      ),
      (-> initiation.resolve())
    )
  else
    MpUser.notLoggedIn ->
      initiation.resolve()

  # Return
  # ----------------------------------------
  return initiation.promise
]