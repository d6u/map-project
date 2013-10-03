app.service 'SearchPrediction', ['TheMap', '$q', '$rootScope', class SearchPrediction

  constructor: (TheMap, $q, $rootScope) ->

    @$autocompleteService = new google.maps.places.AutocompleteService
    @$lastPredictions     = []


    # return promise
    #   resolve: predictions
    #   reject: google service status
    @getSearchPredictions = (input, offset) ->
      gotPredictions = $q.defer()
      @$autocompleteService.getQueryPredictions {
        bounds: TheMap.getMap()?.getBounds()
        input:  input
        offset: offset
      }, (predictions, status) =>
        if status == google.maps.DirectionsStatus.OK
          @$lastPredictions = predictions
          $rootScope.$apply -> gotPredictions.resolve(predictions)
        else
          $rootScope.$apply -> gotPredictions.reject(status)
      gotPredictions.promise
]
