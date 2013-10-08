app.directive 'mdDrawer',
['$rootScope','$timeout','$routeSegment',
( $rootScope,  $timeout,  $routeSegment) ->

  templateUrl: '/scripts/ng-components/drawer/md-drawer.html'
  controllerAs: 'drawerCtrl'
  controller: ['$scope', '$element', 'TheMap', class DrawerCtrl

    constructor: ($scope, $element, TheMap) ->

      @showPlaceOnMap = (place) ->
        TheMap.setMapCenter(place.$$marker.getPosition())
        google.maps.event.trigger(place.$$marker, 'click')
  ]
  link: (scope, element, attrs, drawerCtrl) ->
]