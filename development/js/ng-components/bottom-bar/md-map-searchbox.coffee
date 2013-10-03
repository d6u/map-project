app.directive 'mdMapSearchbox', [->

  controllerAs: 'MdMapSearchBoxCtrl'
  controller: ['ThePlacesSearch', 'TheMap', 'mpTemplateCache', '$scope', '$compile', 'SearchPrediction',
    class MdMapSearchBoxCtrl

      constructor: (ThePlacesSearch, TheMap, mpTemplateCache, $scope, $compile, SearchPrediction) ->

        @placePredictions         = []
        @searchResultsInfoWindows = []

        # --- Callbacks ---
        generateInfoWindowForPlace = (place, marker) =>
          mpTemplateCache.get('/scripts/ng-components/map/marker-info.html')
          .then (template) =>
            newScope        = $scope.$new()
            newScope.place  = place
            @searchResultsInfoWindows.push TheMap.bindInfoWindowToMarker(marker, template, newScope)


        # --- Actions ---
        @getQueryPredictions = (input, offset) =>
          if input.length
            SearchPrediction.getSearchPredictions(input, offset)
            .then (predictions) =>
              @placePredictions = predictions
          else
            $scope.$apply => @placePredictions = []

        @queryPlacesService = (input, offset) =>
          if input.length
            ThePlacesSearch.searchPlacesWith(input).then (results) =>
              TheMap.clearMarkers(_.map(@placeSearchResults, '$$marker'))
              TheMap.removeInfoWindows(@searchResultsInfoWindows)
              @searchResultsInfoWindows = []
              @placeSearchResults       = results
              if results.length
                bounds = new google.maps.LatLngBounds
                animation = if results.length == 1 then google.maps.Animation.DROP else null
                for place in results
                  place.$$marker = new google.maps.Marker {
                    title:     place.name
                    position:  place.geometry.location
                    animation: animation
                  }
                  place.notes    = null
                  place.address  = place.formatted_address
                  place.coord    = place.geometry.location.toString()
                  generateInfoWindowForPlace(place, place.$$marker)
                TheMap.addMarkersOnMap(_.map(@placeSearchResults, '$$marker'), true)
            @placePredictions = [] # close typehead menu
  ]
  link: (scope, element, attrs, MdMapSearchBoxCtrl) ->
]
