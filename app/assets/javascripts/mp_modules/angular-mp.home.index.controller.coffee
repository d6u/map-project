app = angular.module('angular-mp.home.index.controller', [])

# AllProjectsCtrl
app.controller('AllProjectsCtrl',
['$scope',
($scope) ->

])

# ProjectCtrl
app.controller('ProjectCtrl',
['$scope',
($scope) ->
  rearrangeMarkerIcons = ->
    place.marker.setIcon({url: "/assets/number_#{index}.png"}) for place, index in $scope.places

  $scope.places = []

  $scope.addPlaceToList = (place) ->
    if $scope.interface.hidePlacesList
      $scope.interface.hidePlacesList = false
      $scope.interface.sideBarPlacesSlideUp = false
    place.marker.setMap(null)
    place.marker = new google.maps.Marker({
      map: $scope.googleMap.map
      title: place.name
      position: place.place.geometry.location
      icon:
        url: "/assets/number_#{$scope.places.length}.png"
    })
    $scope.places.push place
    if $scope.places.length > 1 && !$scope.user.email
      $scope.interface.showCreateAccountPromot = true

  $scope.centerPlaceInMap = (marker) ->
    marker.getMap().setCenter marker.getPosition()

  $scope.removePlace = (index, marker) ->
    marker.setMap(null)
    $scope.places.splice(index, 1)
    rearrangeMarkerIcons()
])
