#= require libraries/socket.io.min.js
#= require libraries/jquery.js
#= require libraries/jquery-ui-1.10.3.custom.min.js
#= require libraries/masonry.pkgd.min.js
#= require libraries/bootstrap.min.js
#= require libraries/perfect-scrollbar-0.4.3.min.js
#= require libraries/perfect-scrollbar-0.4.3.with-mousewheel.min.js
#= require libraries/angular.min.js
#= require libraries/angular-resource.min.js
#= require modules_for_libraries/angular-facebook.coffee
#= require modules_for_libraries/angular-socket.io.coffee
#= require modules_for_libraries/angular-masonry.coffee
#= require modules_for_libraries/angular-perfect-scrollbar.coffee
#= require modules_for_libraries/angular-bootstrap.coffee
#= require modules_for_libraries/angular-jquery-ui.coffee
#= require mp_modules/angular-mp.api.user.coffee
#= require mp_modules/angular-mp.home.index.controller.coffee
#= require mp_modules/angular-mp.home.index.directives.coffee



# declear
app = angular.module 'mapApp', [
  'angular-facebook',
  'angular-socket.io',
  'angular-masonry',
  'angular-perfect-scrollbar',
  'angular-bootstrap',
  'angular-jquery-ui',

  'angular-mp.home.index.controller',
  'angular-mp.home.index.directives',
  'angular-mp.api.user'
]


# config
app.config([
  'FBModuleProvider', 'socketProvider', '$httpProvider', '$routeProvider',
  (FBModuleProvider, socketProvider, $httpProvider, $routeProvider) ->
    # CSRF
    token = angular.element('meta[name="csrf-token"]').attr('content')
    $httpProvider.defaults.headers.common['X-CSRF-Token'] = token

    # socket
    socketProvider.setServerUrl('http://local.dev:4000')

    # route
    $routeProvider
    .when('/')
    .when('/all_projects', {
      controller: 'AllProjectsCtrl'
      templateUrl: 'all_projects_view'
    })
    .when('/new_project', {
      controller: 'ProjectCtrl'
      templateUrl: 'project_view'
    })
    .when('/project/:project_id', {
      controller: 'ProjectCtrl'
      templateUrl: 'project_view'
    })
    .otherwise({redirectTo: '/'})

    # FB
    FBModuleProvider.init({
        appId      : '580227458695144'
        channelUrl : location.origin + '/fb_channel.html'
        status     : true
        cookie     : true
        xfbml      : true
    })
])

# run
app.run([
  '$rootScope', '$route', '$location', '$http', '$q', 'FBModule', 'User',
  ($rootScope, $route, $location, $http, $q, FBModule, User) ->
    # user
    $rootScope.user = {}

    processUserLogin = (user) ->
      angular.extend($rootScope.user, user) if user
      # TODO

    # google map object
    $rootScope.googleMap =
      markers: []

    # interface control
    $rootScope.interface =
      hideChatbox: true
      hidePlacesList: true
      sideBarPlacesSlideUp: true
      showCreateAccountPromot: false

    # login status change
    FBModule.FB.Event.subscribe('auth.authResponseChange', (response) ->
      if response.status == 'connected'
        loggedIn(response.authResponse)
      else if response.status == 'not_authorized'
        notLoggedIn()
      else
        notLoggedIn()
    )

    # check status change
    loggedIn = (authResponse) ->
      FBModule.FB.api('/me', (response) ->
        $rootScope.user.name            = response.name
        $rootScope.user.email           = response.email
        $rootScope.user.fb_access_token = authResponse.accessToken
        $rootScope.user.fb_user_id      = authResponse.userID
        User.login($rootScope.user).then(processUserLogin)
        $rootScope.interface.showCreateAccountPromot = false
        $rootScope.$apply()
      )
      FBModule.FB.api('/me/picture', (response) -> $rootScope.$apply -> $rootScope.user.picture = response.data.url)
      switch $location.path()
        when '/' # TODO: redirect according to user projects
          if true
            $location.path('/new_project')
          else
            $location.path('/all_projects')
        when '/new_project'
          $rootScope.$broadcast('loginWithNewProject')

    notLoggedIn = (reason) ->
      User.logout() if $rootScope.user.email
      $rootScope.user = {}
      if $location.path() == '/'
        $location.path('/new_project')

    FBModule.loginStatus.then null, notLoggedIn

    $rootScope.fbLogout = -> FBModule.FB.logout()
    $rootScope.fbLogin = -> FBModule.FB.login()

    # get user location according to ip
    $rootScope.userLocation = $http.jsonp('http://www.geoplugin.net/json.gp?jsoncallback=JSON_CALLBACK')
    .then (response) ->
      return {
        latitude: response.data.geoplugin_latitude
        longitude: response.data.geoplugin_longitude
      }
])