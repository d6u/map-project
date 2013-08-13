# mp-map-searchbox
app.directive 'mpMapSearchbox', ['TheMap', (TheMap) ->
  (scope, element, attrs) ->

    TheMap.searchBox = new google.maps.places.SearchBox(element[0])
    TheMap.searchBoxReady.resolve()
]
