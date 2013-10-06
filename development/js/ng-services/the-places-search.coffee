app.factory 'ThePlacesSearch',
['TheMap','$q','$rootScope','MapMarkers','MapInfoWindows',
( TheMap,  $q,  $rootScope,  MapMarkers,  MapInfoWindows) ->

  # --- Model ---
  Result = Backbone.Model.extend {
    initialize: (result, options) ->
      @marker = MapMarkers.create({
        title:    @get('name')
        position: @get('geometry').location
      }, {place: @, type: 'place_service'})

      @infoWindows = MapInfoWindows.createInfoWindowForSearchResult(@)


    destroy: ->
      infoWindow.destroy() for infoWindow in @infoWindows
      @marker.destroy()
      @collection?.remove(@)
  }


  # --- Collection ---
  ThePlacesSearch = Backbone.Collection.extend {

    model: Result

    initialize: () ->
      TheMap.on 'initialized', =>
        @$placesService = new google.maps.places.PlacesService(TheMap.getMap())
        @reset()

      if TheMap.getMap()?
        @$placesService = new google.maps.places.PlacesService(TheMap.getMap())

      TheMap.on 'destroyed', =>
        delete @$placesService
        @reset()

      @on 'newSearchResultsAdded', @fitResultsBounds

      @on 'reset', (collection, options) ->
        place.destroy() for place in options.previousModels

      @on 'remove', (place, collection, options) ->
        place.destroy()


    # --- other ---
    searchPlacesWith: (query) ->
      return null if !@$placesService?
      gotResults = $q.defer()
      @$placesService.textSearch {
        bounds: TheMap.getBounds()
        query:  query
      }, (results, status) =>
        $rootScope.$apply =>
          @reset()
          if status == google.maps.DirectionsStatus.OK
            @add(results)
            @trigger('newSearchResultsAdded')
            gotResults.resolve(results)
          else
            gotResults.reject(status)
      return gotResults.promise


    fitResultsBounds: ->
      bounds = new google.maps.LatLngBounds
      bounds.extend place.get('geometry').location for place in @models
      TheMap.setMapBounds(bounds)
  }
  # --- END ThePlacesSearch ---


  return new ThePlacesSearch
]
