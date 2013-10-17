app.factory 'ThePlacesSearch',
['TheMap','$q','$rootScope','MapMarkers','MapInfoWindows','$compile','mpTemplateCache',
( TheMap,  $q,  $rootScope,  MapMarkers,  MapInfoWindows,  $compile,  mpTemplateCache) ->

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
        @collection.$placesService.getDetails {
          reference: @get('reference')
        }, (result, status) =>
          if status == google.maps.places.PlacesServiceStatus.OK
            @set(result)
            mpTemplateCache.get('/scripts/ng-components/map/info-window-detailed.html')
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
