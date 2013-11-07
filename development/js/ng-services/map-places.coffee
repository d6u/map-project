app.factory 'MapPlaces',
['MapMarkers','MapInfoWindows','MpProjects','TheMap','MpUser','PlacesService','Backbone', '$q', 'PushDispatcher', (MapMarkers, MapInfoWindows, MpProjects, TheMap, MpUser, PlacesService, Backbone, $q, PushDispatcher) ->


  # --- Model ---
  Place = Backbone.Model.extend {

    initialize: (attrs, options) ->
      # normalize attributes
      @set({$$saved: true})
      if !attrs.address?
        @set({address: attrs.formatted_address})
      if !attrs.order?
        @set({order:   @collection.length})

      # load details about the place
      if !options.detailSynced
        @getDetails().then => @_detailSynced = true
      else
        @_detailSynced = true

      # marker
      coordMatch = /\((.+), (.+)\)/.exec(attrs.coord)
      latLng     = new google.maps.LatLng(coordMatch[1], coordMatch[2])
      @marker = MapMarkers.create({
        title:    @get('name')
        position: latLng
        icon:
          url: "/img/blue-marker-3d.png"
      }, {place: @, type:  'saved_place'})

      @infoWindows = MapInfoWindows.createInfoWindowForSavedPlaces(@)

      # --- cleanup ---
      @on 'destroy', (model, collection, options) =>
        infoWindow.destroy() for infoWindow in @infoWindows
        @marker.destroy()


    sync: (method, model, options) ->
      if MpUser.getUser()?
        Backbone.sync.apply(@, arguments)

    # --- API ---
    getMarker: ->
      return @marker.getMarker()

    centerInMap: ->
      TheMap.setMapCenter( @getMarker().getPosition() )

    getPosition: ->
      return @getMarker().getPosition()

    openDirectionsInfoWindow: ->
      @infoWindows[1].open(TheMap.getMap(), @getMarker())

    getDetails: ->
      return PlacesService.getDetails(@get('reference')).then (result) =>
        delete result.id
        @set(result)
  }


  # --- Collection ---
  MapPlaces = Backbone.Collection.extend {

    # --- Properties ---
    model:      Place
    comparator: 'order'


    # --- Init ---
    initialize: ->
      TheMap.on 'initialized', =>
        @$placesService = new google.maps.places.PlacesService(TheMap.getMap())

      if TheMap.getMap()?
        @$placesService = new google.maps.places.PlacesService(TheMap.getMap())

      TheMap.on 'destroyed', =>
        delete @$placesService

      @on 'remove', (place, collection, options) ->
        place.destroy()

      PushDispatcher.on('placeAdded'  , => @fetch())
      PushDispatcher.on('placeRemoved', => @fetch())


    initProject: (id, scope) ->
      MpProjects.onceWhile('service:ready', => @$$loadProject(id)) if id?
      @destroyListenerDeregister = scope.$on('$destroy', => @resetService())


    $$loadProject: (id) ->
      MpProjects.findProjectById(id).then (project) =>
        @project = project
        @url     = "/api/projects/#{@project.id}/places"
        @fetch({
          reset: true
          success: =>
            @enter('service:ready')
        })


    resetService: ->
      @destroyListenerDeregister()
      delete @destroyListenerDeregister
      delete @project
      delete @url
      @reset()
      @leave('service:ready')


    # --- Custom Methods ---
    sync: (method, collection, options) ->
      if MpUser.getUser()?
        Backbone.sync.apply(@, arguments)


    # --- API ---
    openAllDirectionsInfoWindows: ->
      MapInfoWindows.closeAllInfoWindow()
      place.openDirectionsInfoWindow() for place in @models


    displayAllMarkers: ->
      if @length
        bounds = new google.maps.LatLngBounds
        bounds.extend(place.getPosition()) for place in @models
        TheMap.fitBounds(bounds)
  }


  return new MapPlaces
]
