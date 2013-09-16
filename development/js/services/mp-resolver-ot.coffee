app.constant 'mpResolverOt',
['MpInitializer','MpUser','$location','$q','$timeout',
( MpInitializer,  MpUser,  $location,  $q,  $timeout) ->

  deferred = $q.defer()

  MpInitializer.then ->
    $location.path('/dashboard') if MpUser.checkLogin()
    # Resolve after redirection
    $timeout -> deferred.resolve()

  return deferred.promise
]
