# map service
# ========================================
app.factory 'TheMap', [->

  return {
    map: null
    infoWindow: new google.maps.InfoWindow()
    searchBox: null
    markers: []
    searchResults: []
    __searchResults: []
    reset: ->
      @markers = []
      @searchResults = []
      @__searchResults = []
  }
]
