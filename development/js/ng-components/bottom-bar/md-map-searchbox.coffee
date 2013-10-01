app.directive 'mdMapSearchbox', [->

  controllerAs: 'MdMapSearchBoxCtrl'
  controller: ['ThePlacesSearch', 'TheMap', 'mpTemplateCache', '$scope', '$compile',
    class MdMapSearchBoxCtrl

      constructor: (ThePlacesSearch, TheMap, mpTemplateCache, $scope, $compile) ->
        @placePredictions         = []
        @searchResultsInfoWindows = []

        # load info window template in advance to prevent duplicate ajax call
        mpTemplateCache.get('/scripts/ng-components/map/marker-info.html')

        # --- Callbacks ---
        generateInfoWindowForPlace = (place, marker) =>
          mpTemplateCache.get('/scripts/ng-components/map/marker-info.html')
          .then (template) =>
            newScope        = $scope.$new()
            newScope.place  = place
            compiledContent = $compile(template)(newScope)[0]
            @searchResultsInfoWindows.push TheMap.bindInfoWindowToMarker(marker, {content: compiledContent})


        # --- Actions ---
        @getQueryPredictions = ->
          if @searchboxInput.length
            ThePlacesSearch.getSearchPredictions(@searchboxInput)
            .then (predictions) =>
              @placePredictions = predictions

        @queryPlacesService = ->
          if @searchboxInput.length
            ThePlacesSearch.searchPlacesWith(@searchboxInput).then (results) =>
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

    # --- Events ---
    # when user press enter key show search results on map
    # enter key: 13
    element.on 'keypress', (event) ->
      if event.keyCode == 13
        MdMapSearchBoxCtrl.queryPlacesService()

    # Listen to event click event from typeahead menu
    scope.$on 'typeaheadListItemClicked', (event) ->
      event.stopPropagation()
      MdMapSearchBoxCtrl.queryPlacesService()
]
