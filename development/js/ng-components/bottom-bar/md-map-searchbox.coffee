app.directive 'mdMapSearchbox', [->

  controllerAs: 'MdMapSearchBoxCtrl'
  controller: ['ThePlacesSearch', 'TheMap', '$scope', 'SearchPrediction',
    class MdMapSearchBoxCtrl

      constructor: (ThePlacesSearch, TheMap, $scope, SearchPrediction) ->

        # --- Properties ---
        @placePredictions = []


        # --- Actions ---
        @getQueryPredictions = (input, offset) =>
          if input.length
            SearchPrediction.getSearchPredictions(input, offset)
            .then (predictions) =>
              @placePredictions = predictions
          else
            @placePredictions = [] # close typehead menu


        @queryPlacesService = (input) =>
          if input.length
            ThePlacesSearch.searchPlacesWith(input)
            @placePredictions = [] # close typehead menu
  ]
  link: (scope, element, attrs, MdMapSearchBoxCtrl) ->
]
