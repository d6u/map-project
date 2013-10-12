app.factory 'MapPlaces',
['MapMarkers','MapInfoWindows','MpProjects','TheMap','MpUser','$rootScope',
( MapMarkers,  MapInfoWindows,  MpProjects,  TheMap,  MpUser,  $rootScope) ->

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
      @collection.$placesService.getDetails {
        reference: @get('reference')
      }, (result, status) =>
        if status == google.maps.places.PlacesServiceStatus.OK
          $rootScope.$apply =>
            @set(result)
            @infoWindows[0].setContent(@infoWindows[0].getContent())

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
        @collection?.remove(@)


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
  }


  # --- Collection ---
  MapPlaces = Backbone.Collection.extend {

    model:      Place
    comparator: 'order'

    initialize: ->
      TheMap.on 'initialized', =>
        @$placesService = new google.maps.places.PlacesService(TheMap.getMap())

      if TheMap.getMap()?
        @$placesService = new google.maps.places.PlacesService(TheMap.getMap())

      TheMap.on 'destroyed', =>
        delete @$placesService

      @on 'reset', (collection, options) ->
        place.destroy() for place in options.previousModels

      @on 'remove', (place, collection, options) ->
        place.destroy()


    initProject: (id, scope) ->
      @$scope = scope

      if MpProjects.$initializing?
          MpProjects.$initializing.then =>
            @$$loadProject(id)
        else
          @$$loadProject(id)

      @$scope.$on '$destroy', =>
        delete @$scope
        @reset()


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


    # --- Helpers ---
    $$loadProject: (id) ->
      MpProjects.findProjectById(id).then (project) =>
        @project = project
        @url     = "/api/projects/#{@project.id}/places"
        @fetch({reset: true})
  }


  return new MapPlaces
]
