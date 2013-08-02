angular.module('angular-facebook', [])
.provider 'FBModule', class
  # config
  init: (options) -> FB.init(options)

  # factory
  $get: ['$rootScope', '$timeout', '$q', ($rootScope, $timeout, $q) ->

    # build service object
    deferred = $q.defer()
    service =
      FB: FB
      loginStatus: deferred.promise

    # check login status
    FB.getLoginStatus (response) ->
      if response.status == 'connected'
        $rootScope.$apply -> deferred.resolve(response.authResponse)
      else
        $rootScope.$apply -> deferred.reject()

    # return
    return service
  ]
