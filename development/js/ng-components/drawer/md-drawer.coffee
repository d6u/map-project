app.directive 'mdDrawer',
['$rootScope','$timeout','$routeSegment',
( $rootScope,  $timeout,  $routeSegment) ->

  templateUrl: '/scripts/ng-components/drawer/md-drawer.html'
  controllerAs: 'DrawerCtrl'
  controller: ['$scope', '$element', 'TheMap', class DrawerCtrl
    constructor: ($scope, $element, TheMap) ->
  ]
  link: (scope, element, attrs, DrawerCtrl) ->
]
