app.controller 'MapCtrl',
['$scope','$routeSegment','TheMap','ThePlacesSearch','MapMarkers',
'MapPlaces','MapInfoWindows','MapDirections','MpUI', class MapCtrl

  constructor: ($scope, $routeSegment, TheMap, ThePlacesSearch, MapMarkers,
  MapPlaces, MapInfoWindows, MapDirections, MpUI) ->

    # --- Callbacks ---
    # helper
    bindClickSaveToSearchResult = (searchResults) =>
      for place in searchResults
        place.marker.getMarker().addListener 'click', =>
          $scope.$apply =>
            @addPlaceToList(place.attributes)


    # --- Init Services ---
    MapInfoWindows.setMapScope($scope)

    @ThePlacesSearch = ThePlacesSearch
    @MapDirections   = MapDirections


    # --- Listeners ---
    MapPlaces.on 'all', =>
      @savedPlaces = MapPlaces.models


    ThePlacesSearch.on 'newSearchResultsAdded', =>
      ThePlacesSearch.forEach (place) =>
        place.getMarker().addListener 'click', =>
          $scope.$apply =>
            @addPlaceToList(place)


    # --- Actions ---
    @centerSearchResult = (place) ->
      place.centerInMap()
      google.maps.event.trigger place.getMarker(), 'rightclick'


    @centerSavedPlace = (place) ->
      place.centerInMap()
      google.maps.event.trigger place.getMarker(), 'click'


    @addPlaceToList = (place) ->
      place.destroy()
      place.set({ coord: place.get('geometry').location.toString() })
      delete place.attributes.id
      MapPlaces.create(place.attributes, {detailSynced: place._detailSynced})


    @removePlaceFromList = (place) ->
      MapPlaces.remove(place)


    # map control
    @zoomIn = ->
      TheMap.zoomIn()

    @zoomOut = ->
      TheMap.zoomOut()

    @displayAllMarkers = ->
      MapMarkers.displayAllMarkers()

    @openAllDirectionsInfoWindows = ->
      if !MapDirections.$autoRender
        @toggleDirectionsAutoRender()
      MapPlaces.openAllDirectionsInfoWindows()
      MapPlaces.displayAllMarkers()

    @toggleDirectionsAutoRender = ->
      MapDirections.toggleAutoRender()


    # UI control
    @toggleSavedPlacesList = ->
      if MpUI.mapDrawerActiveSection == 'places' && MpUI.showMapDrawer
        MpUI.showMapDrawer = false
      else
        MpUI.mapDrawerActiveSection = 'places'
        MpUI.showMapDrawer = true
]
