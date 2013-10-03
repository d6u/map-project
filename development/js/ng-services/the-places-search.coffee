app.factory 'ThePlacesSearch',
['TheMap','$q','$rootScope',
( TheMap,  $q,  $rootScope) ->

  class ThePlacesSearch
    constructor: ->
      @$lastSearchResults = []

      # initialize according to TheMap service
      TheMap.on 'initialized', =>
        @$placesService = new google.maps.places.PlacesService(TheMap.getMap())
        @$lastSearchResults = []

      if TheMap.getMap()?
        @$placesService = new google.maps.places.PlacesService(TheMap.getMap())

      TheMap.on 'destroyed', =>
        delete @$placesService
        @$lastSearchResults = []


      # return promise
      #   resolve: search results
      #   reject:  google service status
      @searchPlacesWith = (query) ->
        return null if !@$placesService?
        gotResults = $q.defer()
        @$placesService.textSearch {
          bounds: TheMap.getMap()?.getBounds()
          query:  query
        }, (results, status) =>
          if status == google.maps.DirectionsStatus.OK
            @$lastSearchResults = results
            $rootScope.$apply -> gotResults.resolve(results)
          else
            $rootScope.$apply -> gotResults.reject(status)
        gotResults.promise


      @removePlaceFromResults = (place) ->
        @$lastSearchResults = _.without(@$lastSearchResults, place)

      @getLastSearchResults = -> @$lastSearchResults

  # --- END ---
  return new ThePlacesSearch
]
