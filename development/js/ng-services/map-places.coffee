app.factory 'MapPlaces',
['MapMarkers', 'MapInfoWindows', (MapMarkers, MapInfoWindows) ->

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

      @on 'destroy', (model, collection, options) ->
        console.debug model, collection, options


    getMarker: ->
      return @marker.getMarker()

    sync: (method, model, options) ->



  }


  # --- Collection ---
  MapPlaces = Backbone.Collection.extend {

    model: Place
    # url: "/projects"

    initialize: ->


    sync: (method, collection, options) ->
      console.debug method, collection, options
  }


  return new MapPlaces
]
