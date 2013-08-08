#= require libraries/lodash.js
#= require libraries/socket.io.min.js
#= require libraries/jquery-ui-1.10.3.custom.min.js
#= require libraries/jquery.easyModal.js
#= require libraries/masonry.pkgd.min.js
#= require libraries/bootstrap.min.js
#= require libraries/perfect-scrollbar-0.4.3.min.js
#= require libraries/perfect-scrollbar-0.4.3.with-mousewheel.min.js

#= require libraries/angular.min.js
#= require libraries/restangular.js

#= require modules_for_libraries/angular-easy-modal.coffee
#= require modules_for_libraries/angular-socket.io.coffee
#= require modules_for_libraries/angular-masonry.coffee
#= require modules_for_libraries/angular-perfect-scrollbar.coffee
#= require modules_for_libraries/angular-bootstrap.coffee
#= require modules_for_libraries/angular-jquery-ui.coffee

#= require mp_modules/angular-mp.home.initializer.coffee
#= require mp_modules/angular-mp.api.coffee
#= require mp_modules/angular-mp.home.map.coffee
#= require mp_modules/angular-mp.home.toolbar.coffee
#= require mp_modules/angular-mp.home.outside-view.coffee
#= require mp_modules/angular-mp.home.all-projects-view.coffee
#= require mp_modules/angular-mp.home.new-project-view.coffee
#= require mp_modules/angular-mp.home.project-view.coffee

#= require mp_modules/angular-mp.home.helpers.coffee



# declear
app = angular.module 'mapApp', [
  'restangular',

  'angular-easy-modal',
  'angular-socket.io',
  'angular-masonry',
  'angular-perfect-scrollbar',
  'angular-bootstrap',
  'angular-jquery-ui',

  'angular-mp.home.initializer',
  'angular-mp.api',
  'angular-mp.home.map',
  'angular-mp.home.toolbar',
  'angular-mp.home.outside-view',
  'angular-mp.home.all-projects-view',
  'angular-mp.home.new-project-view',
  'angular-mp.home.project-view',

  'angular-mp.home.helpers' # TODO: remove
]


# config
app.config([
  'socketProvider', '$httpProvider', '$routeProvider',
  '$locationProvider',
  (socketProvider, $httpProvider, $routeProvider,
   $locationProvider) ->

    # route
    $routeProvider
    .when('/', {
      controller: 'OutsideViewCtrl'
      templateUrl: 'outside_view'
      resolve:
        User: 'User'
    })
    .when('/all_projects', {
      controller: 'AllProjectsViewCtrl'
      templateUrl: 'all_projects_view'
      resolve:
        User: 'User'
        socket: 'socket'
    })
    .when('/new_project', {
      controller: 'NewProjectViewCtrl'
      templateUrl: 'new_project_view'
      resolve:
        User: 'User'
        socket: 'socket'
    })
    .when('/project/:project_id', {
      controller: 'ProjectViewCtrl'
      templateUrl: 'project_view'
      resolve:
        User: 'User'
        socket: 'socket'
    })
    .otherwise({redirectTo: '/'})

    $locationProvider.html5Mode true

    # CSRF
    token = angular.element('meta[name="csrf-token"]').attr('content')
    $httpProvider.defaults.headers.common['X-CSRF-Token'] = token

    # google map
    google.maps.visualRefresh = true

    # socket
    socketProvider.setServerUrl location.protocol + '//' + location.hostname + ':4000'
])


# run
app.run(['$rootScope', '$location', 'User',
($rootScope, $location, User) ->

  User.then (User) ->
    $rootScope.User = User
    # filter
    if $rootScope.User.fb_access_token()
      $location.path('/all_projects') if $location.path() == '/'
    else
      $location.path('/') if $location.path() != '/'

  $rootScope.interface =
    showUserSection: false
    showChatbox: false
    showPlacesList: false
    sideBarPlacesSlideUp: true
    showCreateAccountPromot: false

  # callbacks
  loginSuccess = ->
    if $rootScope.currentProject.places.length > 0
      $location.path('/new_project')
    else
      $location.path('/all_projects')

  logoutSuccess = ->
    $location.path('/')

  # events
  $rootScope.$on '$routeChangeSuccess', (event, current) ->
    switch current.$$route.controller
      when 'OutsideViewCtrl'
        $rootScope.inMapview = true
      when 'AllProjectsViewCtrl'
        $rootScope.inMapview = false
      when 'NewProjectViewCtrl'
        $rootScope.inMapview = true
      when 'ProjectViewCtrl'
        $rootScope.inMapview = true
])


# mp-user-section
app.directive 'mpUserSection', ['$rootScope', '$compile', '$templateCache',
'User',
($rootScope, $compile, $templateCache, User) ->

  getTemplate = ->
    if $rootScope.User.fb_access_token()
      return $templateCache.get 'mp_user_section_tempalte_login'
    else
      return $templateCache.get 'mp_user_section_tempalte_logout'

  # return
  link: (scope, element, attrs) ->

    scope.interface.showUserSection = false
    scope.$on '$routeChangeSuccess', (event, current) ->
      template = getTemplate()
      html = $compile(template)(scope)
      element.html html
]
