app.controller 'MapCtrl',
['$scope','TheProject','$routeSegment','TheMap','ThePlacesSearch','MapMarkers',
'MapPlaces','MapInfoWindows','MapDirections','ParticipatingUsers', class MapCtrl

  constructor: ($scope, TheProject, $routeSegment, TheMap, ThePlacesSearch,
    MapMarkers, MapPlaces, MapInfoWindows, MapDirections, ParticipatingUsers) ->

    # --- Callbacks ---
    # helper
    bindClickSaveToSearchResult = (searchResults) =>
      for place in searchResults
        place.marker.getMarker().addListener 'click', =>
          $scope.$apply =>
            @addPlaceToList(place.attributes)


    # --- initialization ---
    @MapPlaces       = MapPlaces
    @ThePlacesSearch = ThePlacesSearch
    @MapDirections   = MapDirections

    MapInfoWindows.setMapScope($scope)

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
      place.set({
        coord: place.get('geometry').location.toString()
      })
      delete place.attributes.id
      MapPlaces.create(place.attributes)

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
]
