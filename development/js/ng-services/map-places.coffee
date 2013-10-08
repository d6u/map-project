app.factory 'MapPlaces',
['MapMarkers','MapInfoWindows','MpProjects','TheMap','MpUser',
( MapMarkers,  MapInfoWindows,  MpProjects,  TheMap,  MpUser) ->

  # --- Model ---
  Place = Backbone.Model.extend {
    initialize: (attrs, options) ->
      # normalize attributes
      @set({$$saved: true})
      if attrs.formatted_address?
        @set({address: attrs.formatted_address})

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
  }


  # --- Collection ---
  MapPlaces = Backbone.Collection.extend {

    model: Place

    initialize: ->
      @on 'reset', (collection, options) ->
        place.destroy() for place in options.previousModels
      @on 'remove', (place, collection, options) ->
        place.destroy()

    loadProject: (scope, projectId) ->
      if projectId
        if MpProjects.$initializing?
          MpProjects.$initializing.then =>
            MpProjects.findProjectById(projectId).then (project) =>
              @project = project
              @url     = "/api/projects/#{@project.id}/places"
              @fetch()
        else
          MpProjects.findProjectById(projectId).then (project) =>
            @project = project
            @url     = "/api/projects/#{@project.id}/places"
            @fetch()


    sync: (method, collection, options) ->
      if MpUser.getUser()?
        Backbone.sync.apply(@, arguments)
  }


  return new MapPlaces
]
