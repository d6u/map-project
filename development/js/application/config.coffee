# declear
app = angular.module('mapApp', [
  'ngAnimate',
  'ngRoute',
  'route-segment',
  'view-segment',

  'restangular',
  'angular-perfect-scrollbar',
  'angular-bootstrap',
  'angular-jquery-ui',
  'mini-typeahead',

  'md-tabset',

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
  .when('/',                         'ot')
  .when('/home',                     'in.home')
  .when('/home/project/:project_id', 'in.project')

  # ot
  .segment('ot', {
    templateUrl:  '/scripts/views/outside-view.html'
    controller:   'OutsideViewCtrl'
    controllerAs: 'mapViewCtrl'
    resolve:
      MpInitializer: 'MpInitializer'
  })

  # in
  .segment('in', {
    templateUrl:  '/scripts/views/inside-view.html'
    controller:   'InsideViewCtrl'
    controllerAs: 'insideViewCtrl'
    resolve:
      MpInitializer: 'MpInitializer'
  })
  .within('in')

    .segment('home', {
      templateUrl:  '/scripts/views/in/dashboard-view/dashboard-view.html'
      controller:   'DashboardViewCtrl'
      controllerAs: 'dashboardViewCtrl'
    })

    .segment('project', {
      templateUrl:  '/scripts/views/in/project-view/project-view.html'
      controller:   'ProjectViewCtrl'
      controllerAs: 'mapViewCtrl'
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
