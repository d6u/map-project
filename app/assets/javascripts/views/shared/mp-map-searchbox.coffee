# mp-map-searchbox
app.directive 'mpMapSearchbox', [->
  (scope, element, attrs) ->

    scope.TheMap.searchBox = new google.maps.places.SearchBox(element[0])

    scope.hideHomepage = ->
      if scope.interface.centerSearchBar
        scope.interface.centerSearchBar = false
        # scope.interface.showMapDrawer = true

    # events
    # ----------------------------------------
    scope.$watch 'searchbox.input.length', (newVal) ->
      if newVal > 0
        console.debug()
        # scope.interface.showMapDrawer = true

    # the first time attaching this listener, event will trigger once
    google.maps.event.addListener scope.TheMap.map, 'bounds_changed', ->
      scope.TheMap.searchBox.setBounds scope.TheMap.map.getBounds()

    google.maps.event.addListener scope.TheMap.searchBox, 'places_changed', ->
      scope.$apply -> scope.TheMap.searchResults = scope.TheMap.searchBox.getPlaces()
]
