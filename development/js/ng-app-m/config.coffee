# declear
app = angular.module('mapApp', [
  # 3rd party modules
  'ngAnimate',
  'ngRoute',
  'route-segment',
  'view-segment',
  'restangular',

  # Self made modules

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
  .when('/mobile',                     'ot')
  .when('/mobile/dashboard',           'in.dashboard')
  .when('/mobile/project/:project_id', 'in.project')

  # ot
  .segment('ot', {
    templateUrl:  '/scripts/views/ot-m/outside-view.html'
    controller:   'OutsideViewCtrl'
    controllerAs: 'outsideViewCtrl'
    resolve:
      MpInitializer: 'MpInitializer'
      # action filter
      redirect_to_inside_if_login: ['MpInitializer', 'MpUser', '$location', '$q', '$timeout', (MpInitializer, MpUser, $location, $q, $timeout) ->

        deferred = $q.defer()
        MpInitializer.then ->
          if MpUser.checkLogin()
            $location.path('/mobile/dashboard')
          # Resolve after redirection
          $timeout ->
            deferred.resolve()
        return deferred.promise
      ]
  })

  # in
  .segment('in', {
    templateUrl:  '/scripts/views/in-m/inside-view.html'
    controller:   'InsideViewCtrl'
    controllerAs: 'insideViewCtrl'
    resolve:
      MpInitializer: 'MpInitializer'
      # action filter
      redirect_to_outside_if_not_login: ['MpInitializer', 'MpUser', '$location', '$q', '$timeout', (MpInitializer, MpUser, $location, $q, $timeout) ->

        deferred = $q.defer()
        MpInitializer.then ->
          if !MpUser.checkLogin()
            $location.path('/mobile')
          # Resolve after redirection
          $timeout ->
            deferred.resolve()
        return deferred.promise
      ]
  })
  .within('in')

    .segment('dashboard', {
      templateUrl:  '/scripts/views/in-m/dashboard/dashboard-view.html'
      controller:   'DashboardViewCtrl'
      controllerAs: 'dashboardViewCtrl'
    })

    .segment('project', {
      templateUrl:  '/scripts/views/in-m/project/project-view.html'
      controller:   'ProjectViewCtrl'
      controllerAs: 'projectViewCtrl'
    })

  # otherwise
  $routeProvider.otherwise({redirectTo: '/mobile'})

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
