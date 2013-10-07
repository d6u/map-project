app.controller 'MapCtrl',
['$scope', 'TheProject', '$routeSegment', 'TheMap', 'ThePlacesSearch', 'MapMarkers',
'MapPlaces',
class MapCtrl

  constructor: ($scope, TheProject, $routeSegment, TheMap, ThePlacesSearch, MapMarkers, MapPlaces) ->

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

    MapPlaces.loadProject($scope, $routeSegment.$routeParams.project_id)

    ThePlacesSearch.on 'newSearchResultsAdded', =>
      ThePlacesSearch.forEach (place) =>
        place.getMarker().addListener 'click', =>
          $scope.$apply =>
            @addPlaceToList(place)


    # --- Actions ---
    @centerSearchResult = (place) ->
      place.centerInMap()
      google.maps.event.trigger place.getMarker(), 'rightclick'


    @addPlaceToList = (place) ->
      place.destroy()
      place.set({
        coord: place.get('geometry').location.toString()
      })
      delete place.attributes.id
      MapPlaces.create(place.attributes)
]
