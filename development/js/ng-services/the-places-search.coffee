app.factory 'ThePlacesSearch',
['TheMap', '$q', '$rootScope', 'MapMarkers', 'MapInfoWindows', '$compile', 'mpTemplateCache', 'PlacesService', (TheMap, $q, $rootScope, MapMarkers, MapInfoWindows, $compile, mpTemplateCache, PlacesService) ->

  # preload template
  mpTemplateCache.get('/scripts/ng-components/map/info-window-detailed.html')


  # --- Model ---
  Place = Backbone.Model.extend {

    sync: angular.noop # disable sync when destroy

    initialize: (place, options) ->
      @on 'destroy', =>
        infoWindow.destroy() for infoWindow in @infoWindows
        @marker.destroy()

      @marker = MapMarkers.add({
        title:    @get('name')
        position: @get('geometry').location
      }, {
        place: @,
        type: 'place_service'
      })

      @infoWindows = MapInfoWindows.createInfoWindowForSearchResult(@)

      # load place details into info window
      google.maps.event.addListenerOnce @getMarker(), 'rightclick', =>
        if !@_detailSynced
          @getDetails().then => @infoWindows[0].trigger 'detailsLoaded'


    getMarker: ->
      return @marker.getMarker()

    centerInMap: ->
      TheMap.setCenter( @getMarker().getPosition() )

    getDetails: ->
      PlacesService.getDetails(@get('reference')).then (result) =>
        @set(result)
        @_detailSynced = true
  }


  # --- Collection ---
  ThePlacesSearch = Backbone.Collection.extend {

    model: Place

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

      @on 'destroy', (place) =>
        @remove(place)


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
      TheMap.fitBounds(bounds, @length)


    queryFirstThreePlacesDetails: ->
      for i in [0..2]
        if @models[i]?
          @models[i].getDetails()
  }
  # --- END ThePlacesSearch ---


  return new ThePlacesSearch
]
