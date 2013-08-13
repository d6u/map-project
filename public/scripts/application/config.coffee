# declear
app = angular.module('mapApp', [
  'restangular',
  'angular-easy-modal',
  'angular-masonry',
  'angular-perfect-scrollbar',
  'angular-bootstrap',
  'angular-jquery-ui',

  'mp-chatbox-provider'
])


# config
app.config(['MpChatboxProvider', '$httpProvider', '$routeProvider', '$locationProvider',
  (MpChatboxProvider, $httpProvider, $routeProvider, $locationProvider) ->

    # route
    $routeProvider
    .when('/', {
      controller: 'OutsideViewCtrl'
      templateUrl: 'scripts/views/outside_view/outside-view.html'
      resolve:
        User: 'User'
    })
    .when('/all_projects', {
      controller: 'AllProjectsViewCtrl'
      templateUrl: 'scripts/views/all_projects_view/all-projects-view.html'
      resolve:
        User: 'User'
    })
    .when('/new_project', {
      controller: 'NewProjectViewCtrl'
      templateUrl: 'scripts/views/new_project_view/new-project-view.html'
      resolve:
        User: 'User'
    })
    .when('/project/:project_id', {
      controller: 'ProjectViewCtrl'
      templateUrl: 'scripts/views/project_view/project-view.html'
      resolve:
        User: 'User'
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
  ]
)
