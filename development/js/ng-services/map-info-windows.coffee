app.factory 'MapInfoWindows',
['TheMap','$compile','mpTemplateCache','$templateCache','$q',
( TheMap,  $compile,  mpTemplateCache,  $templateCache,  $q) ->

  # preload template
  mpTemplateCache.get('/scripts/ng-components/map/info-window-brief.html')


  # --- Model ---
  InfoWindow = Backbone.Model.extend {

    # --- Properties ---
    sync: angular.noop

    # --- Init ---
    initialize: (attrs, options) ->
      @scope       = options.scope
      @_infoWindow = new google.maps.InfoWindow(attrs)

      # info window content
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
      marker = options.place.getMarker()

      @_infoWindow.addListener 'closeclick', ->
        marker._enableMouseover = true

      if options.event?
        marker.addListener options.event, ->
          that.collection.$mouseOverInfoWindow.close()
          that.collection.closeAllInfoWindows()
          @_enableMouseover = false
          if options.place._detailSynced
            that.open(TheMap.getMap(), marker)
          else
            that.on 'detailsLoaded', ->
            # after details are loaded, wait for images to load
              setTimeout ->
              # wait until next cycle where img tags are all inserted
                allLoaded = []
                $(that._infoWindow.getContent()).find('img').each ->
                  loaded = $q.defer()
                  $(this).on 'load', ->
                    loaded.resolve()
                  allLoaded.push(loaded)
                $q.all(allLoaded).then ->
                  that.close()
                  that.open(TheMap.getMap(), marker)

      @on 'destroy', =>
        @close()
        @scope.$destroy()


    close: ->
      @_infoWindow.close()
      google.maps.event.trigger(@_infoWindow, 'closeclick')

    open: (map, marker) ->
      marker._enableMouseover = false
      @_infoWindow.open.apply(@_infoWindow, arguments)

    getInfoWindow: ->
      return @_infoWindow

    setContent: (content) ->
      @getInfoWindow().setContent(content)

    getContent: ->
      return @getInfoWindow().getContent()
  }


  # --- Collection ---
  MapInfoWindows = Backbone.Collection.extend {

    # --- Properties ---
    $mouseOverInfoWindow: new google.maps.InfoWindow {disableAutoPan: true}
    model: InfoWindow
    sync:  angular.noop


    # --- Init ---
    initialize: ->
      @on 'add', (infoWindow, MapInfoWindows, options) =>
        @bindMouseOverInfoWindow(options.place)

      @on 'destroy', (infoWindow) =>
        @remove(infoWindow)


    # --- Actions ---
    setMapScope: (scope) ->
      @_scope = scope

    createInfoWindowForSearchResult: (place) ->
      return [ @createDetailInfoWindowForSearchResult(place) ]

    createInfoWindowForSavedPlaces: (place) ->
      return [ @createDetailInfoWindowForSavedPlace(place),
               @createDirectionInfoWindowForSavedPlace(place) ]


    # --- mouseover InfoWindow ---
    bindMouseOverInfoWindow: (place) ->
      that   = this
      marker = place.getMarker()
      title  = place.get('name')

      marker.addListener 'mouseover', () ->
        if @_enableMouseover
          that.$mouseOverInfoWindow.setContent(title)
          that.$mouseOverInfoWindow.open(TheMap.getMap(), marker)

      marker.addListener 'mouseout', () =>
        @$mouseOverInfoWindow.close()


    # --- Search Results ---
    createDetailInfoWindowForSearchResult: (place) ->
      return @add({maxWidth: 294}, {
        place:       place
        scope:       @$createScopeForPlace(place)
        templateUrl: '/scripts/ng-components/map/info-window-detailed.html'
        event:       'rightclick'
      })


    # --- Saved Places ---
    createDetailInfoWindowForSavedPlace: (place) ->
      return @add({maxWidth: 294}, {
        place:       place
        scope:       @$createScopeForPlace(place)
        templateUrl: '/scripts/ng-components/map/info-window-detailed.html'
        event:       'click'
      })


    createDirectionInfoWindowForSavedPlace: (place) ->
      return @add({maxWidth: 294}, {
        place:       place
        scope:       @$createScopeForPlace(place)
        templateUrl: '/scripts/ng-components/map/info-window-directions.html'
      })


    # --- Universal ---
    closeAllInfoWindows: ->
      infoWindow.close() for infoWindow in @models


    # --- Helpers --
    $createScopeForPlace: (place) ->
      newScope       = @_scope.$new()
      newScope.place = place
      return newScope
  }
  # --- END MapInfoWindows ---


  return new MapInfoWindows
]
