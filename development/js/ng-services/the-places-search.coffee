app.factory 'ThePlacesSearch', ['TheMap', '$q', (TheMap, $q) ->

  class ThePlacesSearch
    constructor: ->
      @$autocompleteService = new google.maps.places.AutocompleteService
      @$searchResults = []

      # initialize according to TheMap service
      TheMap.on 'initialized', =>
        @$placesService = new google.maps.places.PlacesService(TheMap.getMap())
        @$searchResults = []

      TheMap.on 'destroyed', =>
        delete @$placesService
        @$searchResults = []

      if TheMap.getMap()?
        @$placesService = new google.maps.places.PlacesService(TheMap.getMap())


      # return promise
      #   resolve: predictions
      #   reject: google service status
      @getSearchPredictions = (input) ->
        return null if !TheMap.getMap()?
        gotPredictions = $q.defer()
        @$autocompleteService.getQueryPredictions {
          bounds: TheMap.getMap().getBounds()
          input:  input
        }, (predictions, status) ->
          if status == google.maps.DirectionsStatus.OK
            gotPredictions.resolve(predictions)
          else
            gotPredictions.reject(status)
        gotPredictions.promise


      # return promise
      #   resolve: search results
      #   reject: google service status
      @searchPlacesWith = (query) ->
        return null if !@$placesService?
        @$searchResults = []
        gotResults = $q.defer()
        @$placesService.textSearch {
          bounds: TheMap.getMap().getBounds()
          query:  query
        }, (results, status) =>
          if status == google.maps.DirectionsStatus.OK
            @$searchResults = results
            gotResults.resolve(results)
          else
            gotResults.reject(status)
        gotResults.promise


      @removePlaceFromResults = (place) ->
        @$searchResults = _.without(@$searchResults, place)


  # --- END ---
  return new ThePlacesSearch
]
