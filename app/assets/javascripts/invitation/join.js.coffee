#= require libraries/lodash.js
#= require libraries/jquery.js
#= require libraries/bootstrap.min.js
#= require libraries/angular.min.js
#= require libraries/restangular.js
#= require modules_for_libraries/angular-facebook.coffee
#= require mp_modules/angular-mp.api.coffee


app = angular.module 'mapApp', [
  'restangular',
  'angular-facebook',
  'angular-mp.api'
]


app.config ['FBProvider', '$httpProvider', '$routeProvider',
'$locationProvider',
(FBProvider, $httpProvider, $routeProvider,
$locationProvider) ->

  # route
  $routeProvider
  .when('/', {
    controller: 'InvitationCtrl'
    templateUrl: 'invitation_view'
    resolve:
      FB: 'FB'
  })
  .otherwise({redirectTo: '/'})

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


app.run ['$rootScope', ($rootScope) ->

  $rootScope.user = {}
]


app.controller 'InvitationCtrl',
['$rootScope', '$location', 'FB', '$http', '$window',
($rootScope, $location, FB, $http, $window) ->

  # callbacks
  loginSuccess = ->
    $http.post(location.href, {join: true}).then (response) ->
      if response.data.id
        $window.location.href = $window.location.origin + '/project/' + response.data.id
      else
        $window.location.href = $window.location.origin

  logoutSuccess = ->

  # actions
  $rootScope.fbLogin = ->
    FB.doLogin loginSuccess, logoutSuccess

  $rootScope.fbLogout = -> FB.doLogout logoutSuccess

  $rootScope.joinProject = -> loginSuccess()

]
