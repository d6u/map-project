###
MpInitializer is in charge of initial check of login status
  The reason I didn't attach REST object in `run` is I want `run` method to be
  executed before every service
###

app.factory 'MpInitializer', ['$q', 'MpUser', ($q, MpUser) ->

  initiation = $q.defer()

  MpUser.$$getLoginStatus ((user) ->
    # email in
    initiation.resolve()
  ), ((responseData) ->
    # fb in
    MpUser.fbRememberLogin (-> initiation.resolve()),
                            -> initiation.resolve()
  ), ->
    # out
    initiation.resolve()

  return initiation.promise
]
