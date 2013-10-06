app.controller 'MapCtrl',
['$scope', 'TheProject', '$routeSegment', 'TheMap', 'ThePlacesSearch', class MapCtrl

  constructor: ($scope, TheProject, $routeSegment, TheMap, ThePlacesSearch) ->

    # --- properties ---
    @placeSearchResults = []


    # --- Callbacks ---
    # from Database
    processServerPlacesData = (newIds, oldIds) =>
      for id in _.difference(newIds, oldIds)
        place          = _.find(TheProject.places, {id: id})
        # place.$$saved  = true
        # place.$$marker.setMap(null)
        # place.$$marker = MapMarkers.addMarkerForSavedPlace(place)


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
        TheProject.addPlace(place.attributes)
      else
        ThePlacesSearch.findWhere({id: place.id}).destroy()
        TheProject.addPlace(place)


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
