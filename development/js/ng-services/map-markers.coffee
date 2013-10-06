app.factory 'MapMarkers', ['TheMap', (TheMap) ->

  # --- Model ---
  SearchMarker = Backbone.Model.extend {
    initialize: (attrs, options) ->
      @_marker = new google.maps.Marker(_.assign({map: TheMap.getMap()}, attrs))

    destroy: ->
      @collection.remove(@)
      @setMap(null)

    setMap: (map) ->
      @_marker.setMap(map)

    getPosition: ->
      return @_marker.getPosition()

    getMarker: ->
      return @_marker
  }


  SavedPlaceMarker = Backbone.Model.extend {

  }


  # --- Collection ---
  MapMarkers = Backbone.Collection.extend {

    model: (attrs, options) ->
      if options.type == 'place_service'
        return new SearchMarker(attrs, options)
      else
        return new SavedPlaceMarker(attrs, options)

    create: ->
      return @push.apply(@, arguments)
  }


  return new MapMarkers
]
