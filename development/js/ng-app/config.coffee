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
  'mini-typeahead',
  'md-tabset',
  'md-masonry',
  'md-socket-io',
  'md-collapse'
  'md-section-jumper'

  # Application modules that have to run before `.config`
])


# config
app.config(['socketProvider', '$httpProvider', '$routeSegmentProvider',
'$locationProvider', '$routeProvider', 'RestangularProvider', 'mpResolverOt',
'mpResolverIn',
(socketProvider, $httpProvider, $routeSegmentProvider, $locationProvider,
 $routeProvider, RestangularProvider, mpResolverOt, mpResolverIn) ->

  # Segment Route
  # ----------------------------------------
  $routeSegmentProvider.options.autoLoadTemplates = true

  $routeSegmentProvider
  .when('/',                    'ot')
  .when('/dashboard',           'in.dashboard')
  .when('/project/:project_id', 'in.project')
  .when('/friends',             'in.friends')
  .when('/search',              'in.search')

  # ot
  .segment('ot', {
    templateUrl:  '/scripts/ng-views/ot/outside-view.html'
    controller:   'OutsideViewCtrl'
    controllerAs: 'OutsideViewCtrl'
    resolve:
      MpInitializer:          'MpInitializer'
      redirectToInsideIfLogin: mpResolverOt
  })

  # in
  .segment('in', {
    templateUrl:  '/scripts/ng-views/in/inside-view.html'
    controller:   'InsideViewCtrl'
    controllerAs: 'insideViewCtrl'
    resolve:
      MpInitializer:              'MpInitializer'
      redirectToOutsideIfNotLogin: mpResolverIn
  })
  .within('in')

    .segment('dashboard', {
      templateUrl:  '/scripts/ng-views/dashboard/dashboard-view.html'
      controller:   'DashboardViewCtrl'
      controllerAs: 'dashboardViewCtrl'
    })

    .segment('project', {
      templateUrl:  '/scripts/ng-components/map/md-map.html'
      controller:   'ProjectViewCtrl'
      controllerAs: 'projectViewCtrl'
    })

    .segment('friends', {
      templateUrl:  '/scripts/ng-views/friends/friends-view.html'
      controller:   'FriendsViewCtrl'
      controllerAs: 'friendsViewCtrl'
    })

    .segment('search', {
      templateUrl:  '/scripts/ng-views/search/search-view.html'
      controller:   'SearchViewCtrl'
      controllerAs: 'searchViewCtrl'
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
  socketProvider.setSocketServer("#{location.protocol}//#{location.hostname}:4000")


  # --- Restangular ---
  convertTimestampToUnix = (element) ->
    if element.created_at
      element.created_at = (new Date).setISO8601(element.created_at)
    if element.updated_at
      element.updated_at = (new Date).setISO8601(element.updated_at)

  RestangularProvider.setBaseUrl('/api')
  RestangularProvider.setResponseInterceptor (data) ->
    if data.length
      for element in data
        convertTimestampToUnix(element)
    else
      convertTimestampToUnix(data)
    return data
])
