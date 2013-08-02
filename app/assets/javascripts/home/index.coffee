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
#= require mp_modules/angular-mp.api.coffee
#= require mp_modules/angular-mp.home.map-view.coffee
#= require mp_modules/angular-mp.home.navbar.coffee
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
  'angular-mp.api',
  'angular-mp.home.map-view',
  'angular-mp.home.navbar'
]


# config
app.config([
  'FBProvider', 'socketProvider', '$httpProvider', '$routeProvider',
  (FBProvider, socketProvider, $httpProvider, $routeProvider) ->

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

    # socket
    socketProvider.setServerUrl('http://local.dev:4000')
])

# run
app.run([
  '$rootScope', '$location', 'FB', 'User', 'Project', '$q', '$http',
  ($rootScope, $location, FB, User, Project, $q, $http) ->

    # user
    $rootScope.user = {}

    # init application
    $rootScope.$on 'fbLoggedIn', (event, authResponse) ->
      loginCheckDB = $q.defer()
      loginCheckFB = $q.defer()
      $rootScope.user.fb_access_token = authResponse.accessToken
      $rootScope.user.fb_user_id      = authResponse.userID
      User.login($rootScope.user).then (user) ->
        if user
          $rootScope.user.id = user.id
        else
          loginCheckDB.resolve()
      FB.api '/me', (response) ->
        $rootScope.user.name          = response.name
        $rootScope.user.email         = response.email
        $rootScope.$apply()
        loginCheckFB.resolve()
      FB.api '/me/picture', (response) ->
        $rootScope.user.picture       = response.data.url
        $rootScope.$apply()
      # register if not in the db
      $q.all([loginCheckDB.promise, loginCheckFB.promise]).then ->
        User.register($rootScope.user)

    $rootScope.$on 'fbNotAuthorized', (event) ->
      User.logout()
      $rootScope.user = {}

    $rootScope.$on 'fbNotLoggedIn', (event) ->
      User.logout()
      $rootScope.user = {}

    # navigation
    navigate = ->
      if !$rootScope.user.fb_access_token
        $location.path('/new_project') if $location.path() != '/new_project'
      else
        switch $location.path()
          when '/'
            Project.query (projects) ->
              if projects.length > 0 then $location.path('/all_projects') else $location.path('/new_project')
          # when '/all_projects'
          # when '/new_project'
          # when '/projects/'

    FB.loginChecked.then ->
      navigate()
      $rootScope.$on '$routeChangeStart', navigate

    # google map object
    $rootScope.googleMap =
      markers: []

    # interface control
    $rootScope.interface =
      hideChatbox: true
      hidePlacesList: true
      sideBarPlacesSlideUp: true
      showCreateAccountPromot: false

    $rootScope.fbLogout = -> FB.logout()
    $rootScope.fbLogin = -> FB.login()

    # get user location according to ip
    $rootScope.userLocation = $http.jsonp('http://www.geoplugin.net/json.gp?jsoncallback=JSON_CALLBACK')
    .then (response) ->
      return {
        latitude: response.data.geoplugin_latitude
        longitude: response.data.geoplugin_longitude
      }
])
