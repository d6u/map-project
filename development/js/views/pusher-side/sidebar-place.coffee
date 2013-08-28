# sidebar place
app.directive 'sidebarPlace', ['$templateCache', '$compile',
($templateCache, $compile) ->
  (scope, element, attrs) ->

    # google.maps.event.addListener scope.place.$$marker, 'click', ->
    #   template = $templateCache.get('marker_info_window')
    #   compiled = $compile(template)(scope)
    #   scope.googleMap.infoWindow.setContent(compiled[0])
    #   scope.googleMap.infoWindow.open(scope.place.$$marker.getMap(), scope.place.$$marker)
]
