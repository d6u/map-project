app.controller 'MapCtrl',
['$scope', 'TheProject', '$routeSegment', 'TheMap', 'ThePlacesSearch','MapMarkers', class MapCtrl

  constructor: ($scope, TheProject, $routeSegment, TheMap, ThePlacesSearch, MapMarkers) ->

    # --- properties ---
    @placeSearchResults = []


    # --- Callbacks ---
    # from Google API
    @processPlaceSearchResults = () ->
      results   = ThePlacesSearch.getLastSearchResults()
      bounds    = new google.maps.LatLngBounds
      animation = if results.length == 1 then google.maps.Animation.DROP else null
      for result in results
        marker = MapMarkers.addMarkerForSearchResult(result, {animation: animation})
        @bindClickToSaveForMarker(marker)
        bounds.extend marker.getPosition()
        place = {
          $$marker: marker
          id:       result.id
          name:     result.name
          notes:    null
          address:  result.formatted_address
          coord:    result.geometry.location.toString()
          icon:     result.icon
        }
        @placeSearchResults.push place
      TheMap.setMapBounds(bounds)


    # from Database
    @processServerPlacesDate = (newIds, oldIds) =>
      for id in _.difference(newIds, oldIds)
        place          = _.find(TheProject.places, {id: id})
        place.$$saved  = true
        place.$$marker.setMap(null)
        place.$$marker = MapMarkers.addMarkerForSavedPlace(place)


    # helper
    @bindClickToSaveForMarker = (marker) ->
      marker.addListener 'click', =>
        $scope.$apply =>
          @addPlaceToList( _.find(@placeSearchResults, {$$marker: marker}) )


    @removePlaceFromPlaceSearchResults = (place) ->
      @placeSearchResults = _.without(@placeSearchResults, place)


    # --- initialization ---
    @theProject = TheProject
    if $routeSegment.startsWith('ot')
      TheProject.initialize($scope)
    else
      TheProject.initialize($scope, Number($routeSegment.$routeParams.project_id))


    # --- Actions ---
    @addPlaceToList = (place) ->
      MapMarkers.deletePlaceSearchMarker(place.$$marker)
      @removePlaceFromPlaceSearchResults(place)
      TheProject.addPlace(place)


    # --- Watchers ---
    # pin marker for ThePlacesSearch.getLastSearchResults()
    $scope.$watch (->
      _.pluck(ThePlacesSearch.getLastSearchResults(), 'id')
    ), ((newVal) =>
      MapMarkers.clearMarkersOfSearchResult()
      @placeSearchResults = []
      @processPlaceSearchResults() if newVal.length
    ), true


    # watch for marked places and make marker for them
    $scope.$watch (->
      _.pluck(TheProject.places, 'id').sort()
    ), @processServerPlacesDate, true
]
