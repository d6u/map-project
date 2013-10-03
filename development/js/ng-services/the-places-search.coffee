app.factory 'ThePlacesSearch', ['TheMap', '$q', (TheMap, $q) ->

  class ThePlacesSearch
    constructor: ->
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
