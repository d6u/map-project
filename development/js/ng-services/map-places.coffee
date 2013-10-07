app.factory 'MapPlaces',
['MapMarkers','MapInfoWindows','MpProjects',
( MapMarkers,  MapInfoWindows,  MpProjects) ->

  # --- Model ---
  Place = Backbone.Model.extend {
    initialize: (attrs, options) ->
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
        console.debug model, collection, options
        infoWindow.destroy() for infoWindow in @infoWindows
        @marker.destroy()
        @collection?.remove(@)


    getMarker: ->
      return @marker.getMarker()
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
  }


  return new MapPlaces
]
