app.controller 'MapCtrl',
['$scope', 'TheProject', '$routeSegment', 'TheMap', 'ThePlacesSearch', 'MapMarkers',
'MapPlaces',
class MapCtrl

  constructor: ($scope, TheProject, $routeSegment, TheMap, ThePlacesSearch, MapMarkers, MapPlaces) ->

    # --- properties ---
    @placeSearchResults = []


    # --- Callbacks ---
    # from Database
    processServerPlacesData = (newIds, oldIds) =>



    # helper
    bindClickSaveToSearchResult = (searchResults) =>
      for place in searchResults
        place.marker.getMarker().addListener 'click', =>
          $scope.$apply =>
            @addPlaceToList(place.attributes)


    # --- initialization ---
    @theProject = TheProject
    if $routeSegment.startsWith('ot')
      TheProject.initialize($scope)
    else
      TheProject.initialize($scope, Number($routeSegment.$routeParams.project_id))


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
        MapPlaces.create(place.attributes)
      else
        ThePlacesSearch.findWhere({id: place.id}).destroy()
        place.coord = place.location.toString()
        MapPlaces.create(place)


    # --- Watchers ---
    $scope.$watch (->
      return ThePlacesSearch.pluck('id')
    ), ((newVal) =>
      if newVal
        @placeSearchResults = _.pluck(ThePlacesSearch.models, 'attributes')
    ), true


    # watch for marked places and make marker for them
    $scope.$watch (->
      return _.pluck(TheProject.places, 'id').sort()
    ), processServerPlacesData, true
]
