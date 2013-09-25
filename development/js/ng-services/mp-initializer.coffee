###
MpInitializer is in charge of initial check of login status
  The reason I didn't attach REST object in `run` is I want `run` method to be
  executed before every service
###

app.factory 'MpInitializer', ['$q', 'MpUser', ($q, MpUser) ->

  initiation = $q.defer()

  MpUser.$$getLoginStatus ((user) ->
    initiation.resolve()
  ), ->
    initiation.resolve()

  return initiation.promise
]
