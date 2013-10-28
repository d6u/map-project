app.factory 'ThePlacesSearch',
['TheMap', '$q', '$rootScope', 'MapMarkers', 'MapInfoWindows', '$compile', 'mpTemplateCache', 'PlacesService', (TheMap, $q, $rootScope, MapMarkers, MapInfoWindows, $compile, mpTemplateCache, PlacesService) ->

  # preload template
  mpTemplateCache.get('/scripts/ng-components/map/info-window-detailed.html')


  # --- Model ---
  Result = Backbone.Model.extend {
    initialize: (result, options) ->
      @marker = MapMarkers.create({
        title:    @get('name')
        position: @get('geometry').location
      }, {place: @, type: 'place_service'})

      @infoWindows = MapInfoWindows.createInfoWindowForSearchResult(@)

      # load place details into info window
      google.maps.event.addListenerOnce @getMarker(), 'rightclick', =>
        scope = @infoWindows[0].scope
        @getDetails().then =>
          mpTemplateCache
          .get('/scripts/ng-components/map/info-window-detailed.html')
          .then (template) =>
            @infoWindows[0].setContent($compile(template)(scope)[0])


    destroy: ->
      infoWindow.destroy() for infoWindow in @infoWindows
      @marker.destroy()
      @collection?.remove(@)

    getMarker: ->
      return @marker.getMarker()

    centerInMap: ->
      TheMap.setMapCenter( @getMarker().getPosition() )

    getDetails: ->
      PlacesService.getDetails(@get('reference')).then (result) =>
        @set(result)
  }


  # --- Collection ---
  ThePlacesSearch = Backbone.Collection.extend {

    model: Result

    initialize: () ->
      TheMap.on 'initialized', =>
        @reset()

      TheMap.on 'destroyed', =>
        @reset()

      @on 'newSearchResultsAdded', =>
        @fitResultsBounds()
        @queryFirstThreePlacesDetails()

      @on 'reset', (collection, options) ->
        place.destroy() for place in options.previousModels

      @on 'remove', (place, collection, options) ->
        place.destroy()


    # --- other ---
    searchPlacesWith: (query) ->
      return PlacesService
      .textSearch({query: query})
      .finally( => @reset() )
      .then(
        ((results) =>
          @add(results)
          @trigger('newSearchResultsAdded')
          return results
        ),
        ((status) =>
          throw status
        )
      )


    fitResultsBounds: ->
      bounds = new google.maps.LatLngBounds
      bounds.extend place.get('geometry').location for place in @models
      TheMap.setMapBounds(bounds)


    queryFirstThreePlacesDetails: ->
      for i in [0..2]
        if @models[i]?
          @models[i].getDetails()

  }
  # --- END ThePlacesSearch ---


  return new ThePlacesSearch
]
