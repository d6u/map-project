app.controller 'MapCtrl',
['$scope','TheProject','$routeSegment','mpTemplateCache','$compile','TheMap',
'ThePlacesSearch','MapMarkers',
class MapCtrl
  constructor: ($scope, TheProject, $routeSegment, mpTemplateCache, $compile,
    TheMap, ThePlacesSearch, MapMarkers) ->

    # --- properties ---
    @placeSearchResults = []


    # --- Callbacks ---
    bindClickAddToSaveForMarker = (marker) =>
      marker.addListener 'click', =>
        $scope.$apply =>
          @addPlaceToList( _.find(@placeSearchResults, {$$marker: marker}) )


    # --- initialization ---
    @theProject = TheProject
    if $routeSegment.startsWith('ot')
      TheProject.initialize($scope)
    else
      TheProject.initialize($scope, Number($routeSegment.$routeParams.project_id))


    # --- Actions ---
    @addPlaceToList = (place) ->
      @placeSearchResults = _.without(@placeSearchResults, place)
      TheProject.addPlace(place)


    # --- Watchers ---
    # pin marker for ThePlacesSearch.getLastSearchResults()
    $scope.$watch (->
      _.pluck(ThePlacesSearch.getLastSearchResults(), 'id')
    ), ((newVal) =>
      # clean up
      MapMarkers.clearMarkersOfSearchResult()
      @placeSearchResults = []
      # process results
      results = ThePlacesSearch.getLastSearchResults()
      if results.length
        bounds = new google.maps.LatLngBounds
        animation = if results.length == 1 then google.maps.Animation.DROP else null
        for result in results
          marker = MapMarkers.addMarkerForSearchResult(result, {animation: animation})
          bindClickAddToSaveForMarker(marker)
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
    ), true


    # watch for marked places and make marker for them
    $scope.$watch (-> _.pluck(TheProject.places, 'id')), ((newVal, oldVal) =>
      return if !newVal?
      # re-render marker for each places
      for place, i in TheProject.places
        place.$$saved = true
        if place.$$marker?
          MapMarkers.removeMarkers place.$$marker
          place.$$marker.setMap null
          delete place.$$marker

        place.$$marker = MapMarkers.addMarkerForSavedPlace(place)
    ), true
]
