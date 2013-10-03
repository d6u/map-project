app.controller 'MapCtrl',
['$scope','TheProject','$routeSegment','mpTemplateCache','$compile','TheMap',
'ThePlacesSearch',
class MapCtrl
  constructor: ($scope, TheProject, $routeSegment, mpTemplateCache, $compile,
    TheMap, ThePlacesSearch) ->

    # properties
    @savedPlacesInfoWindows   = []
    @placeSearchResults       = []
    @searchResultsInfoWindows = []

    # load info window template in advance to prevent duplicate ajax call
    mpTemplateCache.get('/scripts/ng-components/map/marker-info.html')

    # --- Callbacks ---
    generateInfoWindowForPlace = (place, marker) =>
      mpTemplateCache.get('/scripts/ng-components/map/marker-info.html')
      .then (template) =>
        newScope        = $scope.$new()
        newScope.place  = place
        TheMap.bindInfoWindowToMarker(marker, template, newScope)


    # --- initialization ---
    @theProject = TheProject
    if $routeSegment.startsWith('ot')
      TheProject.initialize($scope)
    else
      TheProject.initialize($scope, Number($routeSegment.$routeParams.project_id))


    # --- Actions ---
    @addPlaceToList = (place) ->
      @placeSearchResults = _.without @placeSearchResults, place
      TheProject.addPlace(place)


    # --- Watchers ---
    # pin marker for ThePlacesSearch.getLastSearchResults()
    $scope.$watch (->
      _.pluck(ThePlacesSearch.getLastSearchResults(), 'id')
    ), ((newVal) =>
      # clean up
      TheMap.clearMarkers(_.map(@placeSearchResults, '$$marker'))
      TheMap.removeInfoWindows(@searchResultsInfoWindows)
      @placeSearchResults       = []
      @searchResultsInfoWindows = []

      # process results
      results = ThePlacesSearch.getLastSearchResults()
      if results.length
        animation = if results.length == 1 then google.maps.Animation.DROP else null
        for result in results
          marker = new google.maps.Marker {
            title:     result.name
            position:  result.geometry.location
            animation: animation
          }
          place = {
            $$marker: marker
            name:     result.name
            notes:    null
            address:  result.formatted_address
            coord:    result.geometry.location.toString()
            icon:     result.icon
          }
          @placeSearchResults.push place
          generateInfoWindowForPlace(place, place.$$marker).then (infoWindow) =>
            @searchResultsInfoWindows.push infoWindow
        TheMap.addMarkersOnMap(_.map(@placeSearchResults, '$$marker'), true)
    ), true


    # watch for marked places and make marker for them
    $scope.$watch (-> _.pluck(TheProject.places, 'id')), ((newVal, oldVal) =>
      if newVal
        # re-render marker for each places
        for place, i in TheProject.places
          # $$saved is used to hide infoWindow add place button
          place.$$saved = true
          if place.$$marker
            TheMap.clearMarkers(place.$$marker)
            delete place.$$marker
          if place.geometry
            latLog = place.geometry.location
          else
            coordMatch = /\((.+), (.+)\)/.exec place.coord
            latLog = new google.maps.LatLng coordMatch[1], coordMatch[2]
          place.$$marker = new google.maps.Marker {
            title:    place.name
            position: latLog
            icon:
              url: "/img/blue-marker-3d.png"
          }
          generateInfoWindowForPlace(place, place.$$marker).then (infoWindow) =>
            @savedPlacesInfoWindows.push infoWindow
        TheMap.addMarkersOnMap _.pluck(TheProject.places, '$$marker')
    ), true
]
