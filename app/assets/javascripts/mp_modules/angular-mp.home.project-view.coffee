app = angular.module 'angular-mp.home.project-view', []


app.controller 'ProjectViewCtrl',
['$scope', 'Project', 'ActiveProject', 'TheMap', '$location', '$route',
'socket'
($scope, Project, ActiveProject, TheMap, $location, $route, socket) ->

  $scope.socket = socket

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


  savePlace = (place) ->
    place.id = null
    places = ActiveProject.project.all('places')
    places.post(place).then (newPlace) ->
      angular.extend place, newPlace

  # init
  Project.customGET($route.current.params.project_id).then (project) ->
    ActiveProject.project = project
    project.all('users').getList().then (users) ->
      ActiveProject.partcipatedUsers = users
    project.all('places').getList().then (places) ->
      ActiveProject.places = places
      TheMap.mapReady.promise.then ->
        loadPlaceOntoMap place for place in ActiveProject.places

  # events
  $scope.$on 'placeAddedToList', (event, place) ->
    savePlace(place)

  $scope.$on 'placeRemovedFromList', (event, place) ->
    place.$$marker = null
    place.remove()

  $scope.$on 'projectRemoved', (event, project_id) ->
    ActiveProject.project.remove()
    $location.path('/all_projects')
]
