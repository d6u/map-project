app.controller 'MapCtrl',
['$scope', 'TheProject', '$routeSegment', 'TheMap', 'ThePlacesSearch', 'MapMarkers',
'MapPlaces',
class MapCtrl

  constructor: ($scope, TheProject, $routeSegment, TheMap, ThePlacesSearch, MapMarkers, MapPlaces) ->

    # --- properties ---
    @placeSearchResults = []


    # --- Callbacks ---
    # helper
    bindClickSaveToSearchResult = (searchResults) =>
      for place in searchResults
        place.marker.getMarker().addListener 'click', =>
          $scope.$apply =>
            @addPlaceToList(place.attributes)


    # --- initialization ---
    @MapPlaces = MapPlaces
    MapPlaces.loadProject($scope, $routeSegment.$routeParams.project_id)


    ThePlacesSearch.on 'newSearchResultsAdded', =>
      ThePlacesSearch.forEach (place) =>
        place.marker.getMarker().addListener 'click', =>
          $scope.$apply =>
            @addPlaceToList(place)


    # --- Actions ---
    @addPlaceToList = (place) ->
      if place.attributes?
        place.destroy()
        place.set({coord: place.get('geometry').location.toString()})
        delete place.attributes.id
        MapPlaces.create(place.attributes)
      else
        ThePlacesSearch.findWhere({id: place.id}).destroy()
        place.coord = place.location.toString()
        delete place.id
        MapPlaces.create(place)


    # --- Watchers ---
    $scope.$watch (->
      return ThePlacesSearch.pluck('id')
    ), ((newVal) =>
      if newVal
        @placeSearchResults = _.pluck(ThePlacesSearch.models, 'attributes')
    ), true
]
