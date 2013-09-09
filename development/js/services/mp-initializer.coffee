###
MpInitializer is in charge of init check of login status and attach REST
  object onto $rootScope.
  The reason I didn't attach REST object in `run` is I want `run` be executed
  before amount everything
###

app.factory 'MpInitializer',
['$rootScope', '$q', 'MpUser', '$timeout', ($rootScope, $q, MpUser, $timeout) ->

  $rootScope.MpUser = MpUser

  initiation = $q.defer()

  # init
  # ----------------------------------------
  $.when(appPrepare.facebookLoginCheck, appPrepare.ipLocationCheck)
  .then (response, location) ->

    $timeout ->
      # user location
      if location.error
        $rootScope.userLocation = {
          latitude:   36.1000
          longitude: -112.1000
        }
      else
        $rootScope.userLocation = {
          latitude:  location.geoplugin_latitude
          longitude: location.geoplugin_longitude
        }

      # login
      if response.authResponse
        MpUser.fbLoginCallback response.authResponse, null, ->
          initiation.resolve()
      else
        MpUser.fbLogoutCallback null, ->
          initiation.resolve()

  # Return
  # ----------------------------------------
  return initiation.promise
]
