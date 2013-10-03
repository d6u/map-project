app.service 'SearchPrediction', ['TheMap', '$q', class SearchPrediction

  constructor: (TheMap, $q) ->

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
          gotPredictions.resolve(predictions)
        else
          gotPredictions.reject(status)
      gotPredictions.promise
]
