app.factory 'MapInfoWindows',
['TheMap','$compile','mpTemplateCache','$rootScope','$templateCache',
( TheMap,  $compile,  mpTemplateCache,  $rootScope,  $templateCache) ->

  # preload template
  mpTemplateCache.get('/scripts/ng-components/map/marker-info.html')


  # --- Model ---
  InfoWindow = Backbone.Model.extend {
    initialize: (attrs, options) ->
      @_infoWindow = new google.maps.InfoWindow _.assign({
        content: $compile(options.template)(options.scope)[0]
      }, attrs)

      that   = this
      @scope  = options.scope
      marker = options.place.marker.getMarker()

      marker.addListener options.event, ->
        that.collection.$mouseOverInfoWindow.close()
        infoWindow.close() for infoWindow in that.collection.models
        @_enableMouseover = false
        that.open(TheMap.getMap(), marker)

      @_infoWindow.addListener 'closeclick', ->
        marker._enableMouseover = true


    close: ->
      @_infoWindow.close()
      google.maps.event.trigger(@_infoWindow, 'closeclick')

    open: ->
      @_infoWindow.open.apply(@_infoWindow, arguments)

    destroy: ->
      @close()
      @scope.$destroy()
      @collection?.remove(@)
  }


  # --- Collection ---
  MapInfoWindows = Backbone.Collection.extend {

    $mouseOverInfoWindow: new google.maps.InfoWindow {disableAutoPan: true}
    model: InfoWindow

    createInfoWindowForSearchResult: (place) ->
      place.marker.getMarker()._enableMouseover = true
      @bindMouseOverInfoWindow(place)
      return [ @createDetailInfoWindowForSearchResult(place) ]


    createInfoWindowForSavedPlaces: (place) ->
      place.getMarker()._enableMouseover = true
      @bindMouseOverInfoWindow(place)
      return [ @createDetailInfoWindowForSavedPlace(place) ]


    bindMouseOverInfoWindow: (place) ->
      that   = this
      marker = place.marker.getMarker()

      marker.addListener 'mouseover', () ->
        if @_enableMouseover
          that.$mouseOverInfoWindow.setContent(place.get('name'))
          that.$mouseOverInfoWindow.open(TheMap.getMap(), marker)

      marker.addListener 'mouseout', () =>
        @$mouseOverInfoWindow.close()


    # --- Search Results ---
    createDetailInfoWindowForSearchResult: (place) ->
      newScope       = $rootScope.$new()
      newScope.place = place.attributes
      return @create({maxWidth: 320}, {
        place:    place
        scope:    newScope
        template: $templateCache.get('/scripts/ng-components/map/marker-info.html')
        event:    'rightclick'
      })


    # --- Saved Places ---
    createDetailInfoWindowForSavedPlace: (place) ->
      newScope       = $rootScope.$new()
      newScope.place = place.attributes
      return @create({maxWidth: 320}, {
        place:    place
        scope:    newScope
        template: $templateCache.get('/scripts/ng-components/map/marker-info.html')
        event:    'click'
      })


    create: ->
      @push.apply(@, arguments)
  }
  # --- END MapInfoWindows ---


  return new MapInfoWindows
]
