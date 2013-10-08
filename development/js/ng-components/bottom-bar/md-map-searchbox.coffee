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


        @clearSearchResultsOnMap = ->
          @placePredictions = []
          ThePlacesSearch.reset()
  ]
  require: ['^mdBottomBar', 'mdMapSearchbox']
  link: (scope, element, attrs, Ctrls) ->

    Ctrls[0].clearInput = ->
      Ctrls[1].clearSearchResultsOnMap()
      Ctrls[0].inputVal = ''
]
