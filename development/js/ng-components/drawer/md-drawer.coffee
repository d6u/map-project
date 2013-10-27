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



app.filter 'renderPhoto', ->
  return (place) ->
    html = ''
    if place.has('photos')
      for i in [0..2]
        if place.get('photos')[i]?
          url   = place.get('photos')[i].getUrl({maxHeight: 90, maxWidth: 90})
          html += "<img src=\"#{url}\" />"
    return html
