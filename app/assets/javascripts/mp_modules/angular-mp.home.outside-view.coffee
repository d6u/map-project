app = angular.module 'angular-mp.home.outside-view', []


app.controller 'OutsideViewCtrl',
['$scope', 'Place', 'Project', '$location', '$rootScope', '$q', '$timeout',
($scope, Place, Project, $location, $rootScope, $q, $timeout) ->

  # interface
  $scope.inMapview = true

  # methods
  rearrangeMarkerIcons = ->
    place.marker.setIcon({url: "/assets/number_#{index}.png"}) for place, index in $scope.currentProject.places

  $scope.addPlaceToList = (place) ->
    place.id = true
    place.marker.setMap(null)
    place.marker = new google.maps.Marker({
      map: $scope.googleMap.map
      title: place.name
      position: place.place.geometry.location
      icon:
        url: "/assets/number_#{$scope.currentProject.places.length}.png"
    })
    $scope.currentProject.places.push place

  $scope.centerPlaceInMap = (marker) ->
    marker.getMap().setCenter marker.getPosition()

  $scope.removePlace = (index, marker) ->
    marker.setMap(null)
    place = $scope.currentProject.places.splice(index, 1)[0]
    Place.delete {place_id: place.id}
    rearrangeMarkerIcons()

  $scope.displayAllMarkers = ->
    bounds = new google.maps.LatLngBounds()
    for place in $scope.currentProject.places
      bounds.extend(place.marker.getPosition())
    $scope.googleMap.map.fitBounds(bounds)
    $scope.googleMap.map.setZoom(12) if $scope.currentProject.places.length < 3 && $scope.googleMap.map.getZoom() > 12

  $scope.deleteAllSavedPlaces = ->
    if confirm('Are you sure to delete all saved places? This action is irreversible.')
      place.marker.setMap(null) for place in $scope.currentProject.places
      $scope.currentProject.places = []
]
