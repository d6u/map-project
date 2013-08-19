define ['angular'], ->

  # declear
  window.app = angular.module('mapApp', [
    'ngAnimate',
    'ngRoute',
    'route-segment',
    'view-segment',

    'restangular',
    'angular-masonry',
    'angular-perfect-scrollbar',
    'angular-bootstrap',
    'angular-jquery-ui',

    'mp-chatbox-provider'
  ])


  # config
  app.config(['MpChatboxProvider', '$httpProvider', '$routeSegmentProvider',
  '$locationProvider', '$routeProvider',
  (MpChatboxProvider, $httpProvider, $routeSegmentProvider, $locationProvider,
   $routeProvider) ->

    # Filters
    # ========================================
    # MpProjects
    # ----------------------------------------
    insideFilter = ['MpInitializer', '$q', '$timeout', '$rootScope', '$location', 'MpProjects',
    (MpInitializer, $q, $timeout,$rootScope, $location, MpProjects) ->

      filter = $q.defer()

      MpInitializer.then ->
        if $rootScope.MpUser.checkLogin()
          if !MpProjects.projects.length
            MpProjects.getProjects().then ->
              filter.resolve()
          else
            filter.resolve()

      return filter.promise
    ]

    # MpChatbox
    # ----------------------------------------
    filter_MpChatbox = ['MpInitializer', '$q', '$timeout', '$rootScope',
      '$location', 'MpChatbox',
      (MpInitializer, $q, $timeout, $rootScope, $location, MpChatbox) ->

        filter = $q.defer()

        MpInitializer.then ->
          if $rootScope.MpUser.checkLogin()
            if !MpChatbox.socket.online
              MpChatbox.socket.connect().then ->
                MpChatbox.initialize()
          else
            if MpChatbox.socket.online
              MpChatbox.socket.disconnect()
              MpChatbox.destroy()
          filter.resolve()

        return filter.promise
    ]

    # route
    $routeProvider
    .when('/', {
      controller: 'OutsideViewCtrl'
      controllerAs: 'viewCtrl'
      templateUrl: '/scripts/views/outside-view/outside-view.html'
      resolve: {
        MpInitializer: 'MpInitializer'
      }
    })
    .when('/home', {
      controller: 'AllProjectsViewCtrl'
      controllerAs: 'allProjectsCtrl'
      templateUrl: '/scripts/views/all-projects-view/all-projects-view.html'
      resolve: {
        MpInitializer: 'MpInitializer'
        insideFilter: insideFilter
      }
    })
    .when('/home/project/:project_id', {
      controller: 'ProjectViewCtrl'
      controllerAs: 'viewCtrl'
      templateUrl: '/scripts/views/project-view/project-view.html'
      resolve: {
        MpInitializer: 'MpInitializer'
        insideFilter: insideFilter
      }
    })
    .otherwise({redirectTo: '/'})

    $locationProvider.html5Mode(true)

    # CSRF
    token = angular.element('meta[name="csrf-token"]').attr('content')
    $httpProvider.defaults.headers.common['X-CSRF-Token'] = token

    # google map
    google.maps.visualRefresh = true

    # socket
    MpChatboxProvider.setSocketServer(location.protocol + '//' + location.hostname + ':4000')
  ])
