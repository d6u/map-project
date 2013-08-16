# mp-map-searchbox
app.directive 'mpMapSearchbox', [->
  (scope, element, attrs) ->

    scope.TheMap.searchBox = new google.maps.places.SearchBox(element[0])

    # events
    # ----------------------------------------
    # the first time attaching this listener, event will trigger once
    google.maps.event.addListener scope.TheMap.map, 'bounds_changed', ->
      scope.TheMap.searchBox.setBounds scope.TheMap.map.getBounds()

    google.maps.event.addListener scope.TheMap.searchBox, 'places_changed', ->
      scope.$apply -> scope.TheMap.searchResults = scope.TheMap.searchBox.getPlaces()
]
