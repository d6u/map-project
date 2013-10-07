app.factory 'MapInfoWindows',
['TheMap','$compile','mpTemplateCache','$rootScope','$templateCache',
( TheMap,  $compile,  mpTemplateCache,  $rootScope,  $templateCache) ->

  # preload template
  mpTemplateCache.get('/scripts/ng-components/map/marker-info.html')


  # --- Model ---
  InfoWindow = Backbone.Model.extend {
    initialize: (attrs, options) ->
      @scope       = options.scope
      @_infoWindow = new google.maps.InfoWindow(attrs)

      # fix content undefined issue
      if !options.template?
        content = '<div></div>'
        mpTemplateCache.get('/scripts/ng-components/map/marker-info.html')
        .then (template) =>
          @_infoWindow.setContent($compile(template)(options.scope)[0])
      else
        content = $compile(options.template)(options.scope)[0]

      @_infoWindow.setContent(content)

      # listeners
      that   = this
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

    getInfoWindow: ->
      return @_infoWindow

    setContent: (content) ->
      @getInfoWindow().setContent(content)
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


    # --- mouseover InfoWindow ---
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
