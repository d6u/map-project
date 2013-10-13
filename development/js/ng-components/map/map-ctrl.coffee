app.controller 'MapCtrl',
['$scope','$routeSegment','TheMap','ThePlacesSearch','MapMarkers',
'MapPlaces','MapInfoWindows','MapDirections', class MapCtrl

  constructor: ($scope, $routeSegment, TheMap, ThePlacesSearch, MapMarkers,
  MapPlaces, MapInfoWindows, MapDirections) ->

    # --- Callbacks ---
    # helper
    bindClickSaveToSearchResult = (searchResults) =>
      for place in searchResults
        place.marker.getMarker().addListener 'click', =>
          $scope.$apply =>
            @addPlaceToList(place.attributes)


    # --- Init Services ---
    MapInfoWindows.setMapScope($scope)

    childScope = $scope.$new()

    MapPlaces.initProject(
      $routeSegment.$routeParams.project_id,
      childScope)

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
      place.set({
        coord: place.get('geometry').location.toString()
      })
      delete place.attributes.id
      MapPlaces.create(place.attributes)


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
]
