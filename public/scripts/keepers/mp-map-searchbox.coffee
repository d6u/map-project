# mp-map-searchbox
app.directive 'mpMapSearchbox', ['TheMap', (TheMap) ->
  (scope, element, attrs) ->

    TheMap.searchBox = new google.maps.places.SearchBox(element[0])

    # events
    TheMap.searchBox.setBounds TheMap.map.getBounds()
    google.maps.event.addListener TheMap.map, 'bounds_changed', ->
      TheMap.searchBox.setBounds TheMap.map.getBounds()

    google.maps.event.addListener TheMap.searchBox, 'places_changed', ->
      scope.$apply -> TheMap.searchResults = TheMap.searchBox.getPlaces()
]
