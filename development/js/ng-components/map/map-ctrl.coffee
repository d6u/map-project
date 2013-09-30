app.controller 'MapCtrl',
['$scope','TheProject','$routeSegment','mpTemplateCache','$compile','TheMap',
class MapCtrl
  constructor: ($scope, TheProject, $routeSegment, mpTemplateCache, $compile, TheMap) ->

    # --- initialization ---
    @theProject = TheProject
    if $routeSegment.startsWith('ot')
      TheProject.initialize($scope)
    else
      TheProject.initialize($scope, Number($routeSegment.$routeParams.project_id))

    @placePredictions   = []
    @placeSearchResults = []


    # --- actions ---
    @getQueryPredictions = ->
      if @searchboxInput.length
        TheMap.getSearchPredictions(@searchboxInput).then (predictions) =>
          @placePredictions = predictions


    @queryPlacesService = ->
      if @searchboxInput.length
        TheMap.searchPlacesWith(@searchboxInput).then (results) =>
          TheMap.clearMarkers(_.map(@placeSearchResults, '$$marker'))
          @placeSearchResults = results
          if results.length
            bounds = new google.maps.LatLngBounds
            animation = if results.length == 1 then google.maps.Animation.DROP else null
            for place in results
              place.$$marker = new google.maps.Marker {
                title:     place.name
                position:  place.geometry.location
                animation: animation
              }
              place.notes    = null
              place.address  = place.formatted_address
              place.coord    = place.geometry.location.toString()
            TheMap.addMarkersOnMap(_.map(@placeSearchResults, '$$marker'), true)
        @placePredictions = [] # close typehead menu
]
