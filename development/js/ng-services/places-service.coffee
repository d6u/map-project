app.factory 'PlacesService',
['TheMap', '$q', '$rootScope', (TheMap, $q, $rootScope) ->


  class PlacesService
    constructor: ->
      TheMap.on 'initialized', =>
        @$placesService = new google.maps.places.PlacesService(TheMap.getMap())

      if TheMap.getMap()?
        @$placesService = new google.maps.places.PlacesService(TheMap.getMap())

      TheMap.on 'destroyed', =>
        delete @$placesService


      # --- methods ---
      @getDetails = (reference) ->
        found = $q.defer()
        @$placesService.getDetails {reference: reference}, (result, status) ->
          $rootScope.$apply ->
            if status == google.maps.places.PlacesServiceStatus.OK
              found.resolve(result)
            else
              found.reject(status)
        return found.promise


      @textSearch = (request) ->
        found = $q.defer()
        @$placesService.textSearch(
          _.assign({bounds: TheMap.getBounds()}, request),
          ((results, status) ->
            $rootScope.$apply ->
              if status == google.maps.places.PlacesServiceStatus.OK
                found.resolve(results)
              else
                found.reject(status)
          )
        )
        return found.promise


  return new PlacesService
]
