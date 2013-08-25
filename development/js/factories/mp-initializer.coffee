###
MpInitializer is in charge of init check of login status and attach REST
  object onto $rootScope.
  The reason I didn't attach REST object in `run` is I want `run` be executed
  before amount everything
###

app.factory 'MpInitializer',
['$rootScope', '$q', 'MpUser', '$window', '$routeSegment', 'MpProjects', 'MpChatbox', '$timeout',
( $rootScope,   $q,   MpUser,   $window,   $routeSegment,   MpProjects,   MpChatbox,   $timeout) ->

  $rootScope.MpUser = MpUser

  initiation = $q.defer()

  # init
  # ----------------------------------------
  $.when(appPrepare.facebookLoginCheck, appPrepare.ipLocationCheck)
  .then (response, location) ->
    # TODO: add location error handling
    $window.userLocation = {
      latitude:  location.geoplugin_latitude
      longitude: location.geoplugin_longitude
    }

    if response.authResponse
      MpUser.fbLoginCallback response.authResponse, ->
        $timeout ->
          initiation.resolve()
        if $routeSegment.name == 'ot'
          return '/home'
        return
    else
      MpUser.notLoggedIn ->
        $timeout ->
          initiation.resolve()

  # Return
  # ----------------------------------------
  return initiation.promise
]