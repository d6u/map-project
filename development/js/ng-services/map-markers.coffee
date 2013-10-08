app.factory 'MapMarkers', ['TheMap', (TheMap) ->

  # --- Model ---
  SearchMarker = Backbone.Model.extend {
    initialize: (attrs, options) ->
      @_marker = new google.maps.Marker(_.assign({map: TheMap.getMap()}, attrs))

    destroy: ->
      @setMap(null)
      @collection?.remove(@)

    setMap: (map) ->
      @_marker.setMap(map)

    getPosition: ->
      return @_marker.getPosition()

    getMarker: ->
      return @_marker
  }


  SavedPlaceMarker = Backbone.Model.extend {
    initialize: (attrs, options) ->
      @_marker = new google.maps.Marker(_.assign({map: TheMap.getMap()}, attrs))

    getMarker: ->
      return @_marker

    getPosition: ->
      return @getMarker().getPosition()

    setMap: (map) ->
      @getMarker().setMap(map)

    destroy: ->
      @setMap(null)
      @collection?.remove(@)
  }


  # --- Collection ---
  MapMarkers = Backbone.Collection.extend {

    model: (attrs, options) ->
      if options.type == 'place_service'
        return new SearchMarker(attrs, options)
      else if options.type == 'saved_place'
        return new SavedPlaceMarker(attrs, options)

    create: ->
      return @push.apply(@, arguments)

    displayAllMarkers: ->
      if @length
        bounds = new google.maps.LatLngBounds
        bounds.extend(place.getPosition()) for place in @models
        TheMap.fitBounds(bounds)
  }


  return new MapMarkers
]