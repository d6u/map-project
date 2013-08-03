app = angular.module 'angular-facebook', []

app.provider 'FB', class

  # config
  init: (options) -> FB.init options

  # factory
  $get: ['$rootScope', '$timeout', '$q', ($rootScope, $timeout, $q) ->

    # check if logged in
    FB.checkLogin = (loggedIn, notLoggedIn) ->
      FB.getLoginStatus (response) ->
        switch response.status
          when 'connected'
            loggedIn(response.authResponse)
          else
            notLoggedIn()

    FB.doLogin = (success, error) ->
      FB.login (response) ->
        if response.authResponse
          success(response.authResponse)
        else
          error()

    FB.doLogout = (success) ->
      FB.logout -> success()

    # return
    FB
  ]
