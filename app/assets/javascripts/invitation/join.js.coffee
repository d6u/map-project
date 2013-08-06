#= require libraries/lodash.js
#= require libraries/jquery.js
#= require libraries/bootstrap.min.js
#= require libraries/angular.min.js
#= require libraries/angular-resource.min.js
#= require libraries/restangular.js
#= require modules_for_libraries/angular-facebook.coffee
#= require mp_modules/angular-mp.api.coffee


app = angular.module 'mapApp', [
  'restangular',
  'angular-facebook',
  'angular-mp.api'
]


app.config ['FBProvider', '$httpProvider',
  (FBProvider, $httpProvider) ->

    # CSRF
    token = angular.element('meta[name="csrf-token"]').attr('content')
    $httpProvider.defaults.headers.common['X-CSRF-Token'] = token

    # FB
    FBProvider.init({
      appId      : '580227458695144'
      channelUrl : location.origin + '/fb_channel.html'
      status     : true
      cookie     : true
      xfbml      : true
    })
]


app.run ['$rootScope', '$location', 'FB',
  ($rootScope, $location, FB) ->

    # callbacks
    loginSuccess = ->
      if $rootScope.target_project_id
        # $rootScope.user.
      else


    logoutSuccess = ->
      # $location.path('/')

    # resolver
    FB.then (FB) ->
      # filter
      # if $rootScope.user.fb_access_token
      #   $location.path('/all_projects') if $location.path() == '/'
      # else
      #   $location.path('/') if $location.path() != '/'

      # global methods
      $rootScope.fbLogin = (project_id) ->
        $rootScope.target_project_id = project_id
        FB.doLogin loginSuccess, logoutSuccess
      $rootScope.fbLogout = -> FB.doLogout logoutSuccess
]
