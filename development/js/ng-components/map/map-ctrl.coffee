app.controller 'MapCtrl',
['$scope','TheProject','$routeSegment','mpTemplateCache','$compile','TheMap',
'ThePlacesSearch',
class MapCtrl
  constructor: ($scope, TheProject, $routeSegment, mpTemplateCache, $compile,
    TheMap, ThePlacesSearch) ->

    # --- initialization ---
    @theProject = TheProject
    if $routeSegment.startsWith('ot')
      TheProject.initialize($scope)
    else
      TheProject.initialize($scope, Number($routeSegment.$routeParams.project_id))


    # --- Actions ---
    @addPlaceToList = (place) ->
      ThePlacesSearch.removePlaceFromResults(place)
      TheProject.addPlace(place)


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
        TheMap.addMarkersOnMap _.pluck(TheProject.places, '$$marker')
    ), true
]
