app = angular.module 'angular-mp.home.new-project-view', []


app.controller 'NewProjectViewCtrl',
['$scope', '$location', '$rootScope', '$q', '$timeout',
 '$templateCache', '$compile', 'User', 'TheMap',
($scope, $location, $rootScope, $q, $timeout,
 $templateCache, $compile, User, TheMap) ->

  if !User.checkLogin() then return

  # callbacks
  loadPlaceOntoMap = (place) ->
    coordMatch = /\((.+), (.+)\)/.exec place.coord
    latLog = new google.maps.LatLng coordMatch[1], coordMatch[2]
    markerOptions =
      map: TheMap.map
      title: place.name
      position: latLog
      icon:
        url: "/assets/number_#{place.order}.png"

    place.$$marker = new google.maps.Marker markerOptions


  # events
  $scope.$on 'placeAddedToList', (event, place) ->
    savePlace(place)

  $scope.$on 'placeRemovedFromList', (event, place) ->
    place.$$marker = null
    place.remove()

  $scope.$on 'projectUpdated', ->
    $location.path('/project/' + ActiveProject.project.id)

  $scope.$on 'projectRemoved', (event, project_id) ->
    ActiveProject.project.remove()
    $location.path('/all_projects')
]
