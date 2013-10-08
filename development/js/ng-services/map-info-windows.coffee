app.factory 'MapInfoWindows',
['TheMap','$compile','mpTemplateCache','$templateCache',
( TheMap,  $compile,  mpTemplateCache,  $templateCache) ->

  # preload template
  mpTemplateCache.get('/scripts/ng-components/map/info-window-brief.html')


  # --- Model ---
  InfoWindow = Backbone.Model.extend {
    initialize: (attrs, options) ->
      @scope       = options.scope
      @_infoWindow = new google.maps.InfoWindow(attrs)

      # fix content undefined issue
      if options.template?
        content = $compile(options.template)(options.scope)[0]
      else
        template = $templateCache.get(options.templateUrl)
        if template?
          content = $compile(template)(options.scope)[0]
        else
          content = '<div></div>'
          mpTemplateCache.get(options.templateUrl).then (template) =>
            @_infoWindow.setContent($compile(template)(options.scope)[0])

      @_infoWindow.setContent(content)

      # listeners
      that   = this
      marker = options.place.marker.getMarker()

      @_infoWindow.addListener 'closeclick', ->
        marker._enableMouseover = true

      if options.event?
        marker.addListener options.event, ->
          that.collection.$mouseOverInfoWindow.close()
          infoWindow.close() for infoWindow in that.collection.models
          @_enableMouseover = false
          that.open(TheMap.getMap(), marker)


    close: ->
      @_infoWindow.close()
      google.maps.event.trigger(@_infoWindow, 'closeclick')

    open: (map, marker) ->
      marker._enableMouseover = false
      @_infoWindow.open.apply(@_infoWindow, arguments)

    destroy: ->
      @close()
      @scope.$destroy()
      @collection?.remove(@)

    getInfoWindow: ->
      return @_infoWindow

    setContent: (content) ->
      @getInfoWindow().setContent(content)

    getContent: ->
      return @getInfoWindow().getContent()
  }


  # --- Collection ---
  MapInfoWindows = Backbone.Collection.extend {

    $mouseOverInfoWindow: new google.maps.InfoWindow {disableAutoPan: true}
    model: InfoWindow

    create: ->
      @push.apply(@, arguments)

    setMapScope: (scope) ->
      @_scope = scope

    createInfoWindowForSearchResult: (place) ->
      place.marker.getMarker()._enableMouseover = true
      @bindMouseOverInfoWindow(place)
      return [ @createDetailInfoWindowForSearchResult(place) ]


    createInfoWindowForSavedPlaces: (place) ->
      place.getMarker()._enableMouseover = true
      @bindMouseOverInfoWindow(place)
      return [ @createDetailInfoWindowForSavedPlace(place),
               @createDirectionInfoWindowForSavedPlace(place) ]


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
      newScope       = @_scope.$new()
      newScope.place = place
      return @create({maxWidth: 320}, {
        place:       place
        scope:       newScope
        templateUrl: '/scripts/ng-components/map/info-window-brief.html'
        event:       'rightclick'
      })


    # --- Saved Places ---
    createDetailInfoWindowForSavedPlace: (place) ->
      newScope       = @_scope.$new()
      newScope.place = place
      return @create({maxWidth: 320}, {
        place:       place
        scope:       newScope
        templateUrl: '/scripts/ng-components/map/info-window-detailed.html'
        event:       'click'
      })


    createDirectionInfoWindowForSavedPlace: (place) ->
      newScope       = @_scope.$new()
      newScope.place = place
      return @create({maxWidth: 320}, {
        place:       place
        scope:       newScope
        templateUrl: '/scripts/ng-components/map/info-window-directions.html'
      })


    # --- Universal ---
    closeAllInfoWindow: ->
      infoWindow.close() for infoWindow in @models
  }
  # --- END MapInfoWindows ---


  return new MapInfoWindows
]