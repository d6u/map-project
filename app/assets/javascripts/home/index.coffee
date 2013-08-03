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
#= require mp_modules/angular-mp.home.shared.coffee
#= require mp_modules/angular-mp.home.outside-view.coffee
#= require mp_modules/angular-mp.home.all-projects-view.coffee
#= require mp_modules/angular-mp.home.new-project-view.coffee
#= require mp_modules/angular-mp.home.map-view.coffee
#= require mp_modules/angular-mp.home.helpers.coffee



# declear
app = angular.module 'mapApp', [
  'angular-facebook',
  'angular-socket.io',
  'angular-masonry',
  'angular-perfect-scrollbar',
  'angular-bootstrap',
  'angular-jquery-ui',

  'angular-mp.api',
  'angular-mp.home.shared',
  'angular-mp.home.outside-view',
  'angular-mp.home.all-projects-view',
  'angular-mp.home.new-project-view',

  'angular-mp.home.map-view',
  'angular-mp.home.helpers'
]


# config
app.config([
  'FBProvider', 'socketProvider', '$httpProvider', '$routeProvider',
  '$locationProvider',
  (FBProvider, socketProvider, $httpProvider, $routeProvider,
   $locationProvider) ->

    # route
    $routeProvider
    .when('/', {
      controller: 'OutsideViewCtrl'
      templateUrl: 'outside_view'
    })
    .when('/all_projects', {
      controller: 'AllProjectsViewCtrl'
      templateUrl: 'all_projects_view'
    })
    .when('/new_project', {
      controller: 'NewProjectViewCtrl'
      templateUrl: 'new_project_view'
    })
    .when('/project/:project_id', {
      controller: 'ProjectViewCtrl'
      templateUrl: 'project_view'
    })
    .otherwise({redirectTo: '/'})

    $locationProvider.html5Mode true

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
  '$rootScope', '$location', 'FB', 'User', 'Project', '$q', '$http', '$route',
  ($rootScope, $location, FB, User, Project, $q, $http, $route) ->

    # user
    $rootScope.user = {}

    FB.checkLogin ((authResponse) ->
      $rootScope.user.fb_access_token = authResponse.accessToken
      $rootScope.user.fb_user_id      = authResponse.userID
      User.login($rootScope.user).then (user) ->
        if user
          $rootScope.user.id = user.id
          FB.api '/me', (response) ->
            $rootScope.user.name      = response.name
            $rootScope.user.email     = response.email
            User.save($rootScope.user)
          FB.api '/me/picture', (response) ->
            $rootScope.user.picture   = response.data.url
          $location.path('/all_projects') if $location.path() == '/'
        else
          FB.api '/me', (response) ->
            $rootScope.user.name      = response.name
            $rootScope.user.email     = response.email
            User.register $rootScope.user, (user) ->
              $rootScope.user.id = user.id
              $location.path('/new_project') if $location.path() != '/new_project'
    ), (->
      $location.path('/') if $location.path() != '/'
    )

    # map
    $rootScope.userLocation = $http.jsonp('http://www.geoplugin.net/json.gp?jsoncallback=JSON_CALLBACK')
    .then (response) ->
      # get user location according to ip
      latitude: response.data.geoplugin_latitude
      longitude: response.data.geoplugin_longitude

    $rootScope.googleMap =
      mapReady: $q.defer()
      markers: []

    # global objects
    $rootScope.interface =
      showChatbox: false
      showPlacesList: false
      sideBarPlacesSlideUp: true
      showCreateAccountPromot: false

    $rootScope.fbLogout = -> FB.doLogout()
    $rootScope.fbLogin = -> FB.doLogin()

    $rootScope.currentProject =
      project: {}
      places: []





    # # user
    # $rootScope.user = {}

    # # init application
    # $rootScope.$on 'fbLoggedIn', (event, authResponse) ->
    #   loginCheckDB = $q.defer()
    #   loginCheckFB = $q.defer()
    #   $rootScope.user.fb_access_token = authResponse.accessToken
    #   $rootScope.user.fb_user_id      = authResponse.userID
    #   User.login($rootScope.user).then (user) ->
    #     if user
    #       $rootScope.user.id = user.id
    #       $rootScope.localLoggedIn.resolve()
    #     else
    #       loginCheckDB.resolve()


    #   # register if not in the db
    #   $q.all([loginCheckDB.promise, loginCheckFB.promise]).then ->
    #     User.register($rootScope.user).then (user) ->
    #       if user
    #         $rootScope.user.id = user.id
    #         $rootScope.localLoggedIn.resolve()

    # userLogout = ->
    #   User.logout().then -> $location.path('/')
    #   $rootScope.user = {}

    # $rootScope.$on 'fbNotAuthorized', userLogout

    # $rootScope.$on 'fbNotLoggedIn', userLogout

    # # navigation
    # navigate = ->
    #   if !$rootScope.user.fb_access_token
    #     $location.path('/new_project') if $location.path() != '/new_project'
    #   else
    #     switch $location.path()
    #       when '/'
    #         $rootScope.projectsLoaded.promise.then ->
    #           if $rootScope.projects.length > 0 then $location.path('/all_projects') else $location.path('/new_project')
    #       when '/all_projects'
    #         $rootScope.projectsLoaded.promise.then ->
    #           $location.path('/new_project') if $rootScope.projects.length == 0
    #       # when '/new_project'
    #       # else # /project/:project_id
    #         # if /\/project\/\d+/.test $location.path()
    #           # $route.current.params.project_id

    # FB.loginChecked.then ->
    #   navigate()
    #   $rootScope.$on '$routeChangeStart', navigate







    # deferred events
    # $rootScope.localLoggedIn = $q.defer()
    # $rootScope.projectsLoaded = $q.defer()


    # # projects
    # $rootScope.localLoggedIn.promise.then ->
    #   Project.query (projects) ->
    #     $rootScope.projects = projects
    #     $rootScope.projectsLoaded.resolve()

    # $rootScope.$on 'projectDeleted', (event, project_id) ->
    #   Project.query (projects) ->
    #     $rootScope.projects = projects



    # google map object


    # interface control

])
