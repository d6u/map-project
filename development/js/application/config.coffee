# declear
app = angular.module('mapApp', [
  # 3rd party modules
  'ngAnimate',
  'ngRoute',
  'route-segment',
  'view-segment',
  'restangular',

  # Self made modules
  'angular-perfect-scrollbar',
  'angular-bootstrap',
  'angular-jquery-ui',
  'mini-typeahead',
  'md-tabset',

  # Application modules that have to run before `.config`
  'mp-chatbox-provider'
])


# config
app.config(['MpChatboxProvider', '$httpProvider', '$routeSegmentProvider',
'$locationProvider', '$routeProvider',
(MpChatboxProvider, $httpProvider, $routeSegmentProvider, $locationProvider,
 $routeProvider) ->

  # Segment Route
  # ----------------------------------------
  $routeSegmentProvider.options.autoLoadTemplates = true

  $routeSegmentProvider
  .when('/',                    'ot')
  .when('/dashboard',           'in.dashboard')
  .when('/project/:project_id', 'in.project')

  # ot
  .segment('ot', {
    templateUrl:  '/scripts/views/ot/outside-view.html'
    controller:   'OutsideViewCtrl'
    controllerAs: 'outsideViewCtrl'
    resolve:
      MpInitializer: 'MpInitializer'
      # action filter
      redirect_to_inside_if_login: ['MpInitializer', 'MpUser', '$location', '$q', '$timeout', (MpInitializer, MpUser, $location, $q, $timeout) ->

        deferred = $q.defer()
        MpInitializer.then ->
          if MpUser.checkLogin()
            $location.path('/dashboard')
          # Resolve after redirection
          $timeout ->
            deferred.resolve()
        return deferred.promise
      ]
  })

  # in
  .segment('in', {
    templateUrl:  '/scripts/views/in/inside-view.html'
    controller:   'InsideViewCtrl'
    controllerAs: 'insideViewCtrl'
    resolve:
      MpInitializer: 'MpInitializer'
      # action filter
      redirect_to_outside_if_not_login: ['MpInitializer', 'MpUser', '$location', '$q', '$timeout', (MpInitializer, MpUser, $location, $q, $timeout) ->

        deferred = $q.defer()
        MpInitializer.then ->
          if !MpUser.checkLogin()
            $location.path('/')
          # Resolve after redirection
          $timeout ->
            deferred.resolve()
        return deferred.promise
      ]
  })
  .within('in')

    .segment('dashboard', {
      templateUrl:  '/scripts/views/in/dashboard/dashboard-view.html'
      controller:   'DashboardViewCtrl'
      controllerAs: 'dashboardViewCtrl'
    })

    .segment('project', {
      templateUrl:  '/scripts/views/in/project/project-view.html'
      controller:   'ProjectViewCtrl'
      controllerAs: 'projectViewCtrl'
    })

  # otherwise
  $routeProvider.otherwise({redirectTo: '/'})

  $locationProvider.html5Mode(true)

  # CSRF
  # ----------------------------------------
  token = angular.element('meta[name="csrf-token"]').attr('content')
  $httpProvider.defaults.headers.common['X-CSRF-Token'] = token

  # Google Maps
  # ----------------------------------------
  google.maps.visualRefresh = true

  # socket.io
  # ----------------------------------------
  MpChatboxProvider.setSocketServer(location.protocol + '//' + location.hostname + ':4000')
])
