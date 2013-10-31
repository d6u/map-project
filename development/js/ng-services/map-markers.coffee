app.factory 'MapMarkers', ['TheMap', (TheMap) ->

  # --- Model ---
  SearchMarker = SavedPlaceMarker = Backbone.Model.extend {

    sync: angular.noop

    initialize: (attrs, options) ->
      @_marker = new google.maps.Marker(_.assign({map: TheMap.getMap()}, attrs))
      @_marker._enableMouseover = true

      @on 'destroy', => @setMap(null)


    setMap: (map) ->
      @getMarker().setMap(map)

    getPosition: ->
      return @_marker.getPosition()

    getMarker: ->
      return @_marker
  }


  # --- Collection ---
  MapMarkers = Backbone.Collection.extend {

    # --- Properties ---
    model: (attrs, options) ->
      if options.type == 'place_service'
        return new SearchMarker(attrs, options)
      else if options.type == 'saved_place'
        return new SavedPlaceMarker(attrs, options)

    # --- Init ---
    initialize: ->
      @on 'destroy', (marker) =>
        @remove(marker)

    # --- Actions ---
    create: ->
      return @add.apply(@, arguments)

    displayAllMarkers: ->
      if @length
        bounds = new google.maps.LatLngBounds
        bounds.extend(place.getPosition()) for place in @models
        TheMap.fitBounds(bounds, @length)
  }


  return new MapMarkers
]
