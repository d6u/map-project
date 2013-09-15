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
  'md-masonry',
  'md-socket-io',

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
    templateUrl:  '/scripts/views/ot/outside-view.html'
    controller:   'OutsideViewCtrl'
    controllerAs: 'outsideViewCtrl'
    resolve:
      MpInitializer:          'MpInitializer'
      redirectToInsideIfLogin: mpResolverOt
  })

  # in
  .segment('in', {
    templateUrl:  '/scripts/views/in/inside-view.html'
    controller:   'InsideViewCtrl'
    controllerAs: 'insideViewCtrl'
    resolve:
      MpInitializer:              'MpInitializer'
      redirectToOutsideIfNotLogin: mpResolverIn
  })
  .within('in')

    .segment('dashboard', {
      templateUrl:  '/scripts/views/dashboard/dashboard-view.html'
      controller:   'DashboardViewCtrl'
      controllerAs: 'dashboardViewCtrl'
    })

    .segment('project', {
      templateUrl:  '/scripts/views/project/project-view.html'
      controller:   'ProjectViewCtrl'
      controllerAs: 'projectViewCtrl'
    })

    .segment('friends', {
      templateUrl:  '/scripts/views/friends/friends-view.html'
      controller:   'FriendsViewCtrl'
      controllerAs: 'friendsViewCtrl'
    })

    .segment('search', {
      templateUrl:  '/scripts/views/search/search-view.html'
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


  # --- Date ---
  # convert ISO 8601 date string to normal JS Date object
  # usage: new Date.setISO8601( "ISO8601 Time" )
  Date.prototype.setISO8601 = (string) ->
    regexp = "([0-9]{4})(-([0-9]{2})(-([0-9]{2})" +
             "(T([0-9]{2}):([0-9]{2})(:([0-9]{2})(\.([0-9]+))?)?" +
             "(Z|(([-+])([0-9]{2}):([0-9]{2})))?)?)?)?"
    d = string.match(new RegExp(regexp))

    offset = 0
    date = new Date(d[1], 0, 1)

    date.setMonth(d[3] - 1) if d[3]
    date.setDate(d[5])      if d[5]
    date.setHours(d[7])     if d[7]
    date.setMinutes(d[8])   if d[8]
    date.setSeconds(d[10])  if d[10]
    date.setMilliseconds(Number("0." + d[12]) * 1000) if d[12]
    if d[14]
      offset = (Number(d[16]) * 60) + Number(d[17])
      offset *= (if (d[15] == '-') then 1 else -1)

    offset -= date.getTimezoneOffset()
    time = (Number(date) + (offset * 60 * 1000))
    @setTime(Number(time))


  # --- Restangular ---
  convertTimestampToUnix = (element) ->
    if element.created_at
      element.created_at = (new Date).setISO8601(element.created_at)
    if element.updated_at
      element.updated_at = (new Date).setISO8601(element.updated_at)

  RestangularProvider.setBaseUrl('/api')
  RestangularProvider.setResponseInterceptor (data, operation, what, url, response, deferred) ->
    if data.length
      for element in data
        convertTimestampToUnix(element)
    else
      convertTimestampToUnix(data)
    return data
])
