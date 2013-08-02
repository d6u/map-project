app = angular.module 'angular-facebook', []

app.provider 'FB', class

  # config
  init: (options) -> FB.init options

  # factory
  $get: ['$rootScope', '$timeout', '$q', ($rootScope, $timeout, $q) ->

    loginChecked = $q.defer()

    loginCheck = (response) ->
      switch response.status
        when 'connected'
          console.log 'fbLoggedIn'
          $rootScope.$broadcast 'fbLoggedIn', response.authResponse
        when 'not_authorized'
          console.log 'fbNotAuthorized'
          $rootScope.$broadcast 'fbNotAuthorized'
        else
          console.log 'fbNotLoggedIn'
          $rootScope.$broadcast 'fbNotLoggedIn'

    # init
    FB.getLoginStatus (response) ->
      loginCheck response
      FB.Event.subscribe 'auth.authResponseChange', loginCheck
      $rootScope.$apply -> loginChecked.resolve()

    # attach login checked promise
    FB.loginChecked = loginChecked.promise

    # return
    FB
  ]
