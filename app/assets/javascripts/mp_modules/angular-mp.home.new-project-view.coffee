app = angular.module 'angular-mp.home.new-project-view', []


app.controller 'NewProjectViewCtrl',
['$scope', 'Place', 'Project', '$location', '$rootScope', '$q', '$timeout',
 '$templateCache', '$compile',
($scope, Place, Project, $location, $rootScope, $q, $timeout,
 $templateCache, $compile) ->

  $scope.$on 'addedPlace', (event, place) ->
    savePlace(place)

  $scope.$on 'removePlace', (event, place) ->
    Place.delete {project_id: $scope.currentProject.project.id , place_id: place.id}

  # callbacks
  processPlace = (place, index) ->
    coordMatch = /\((.+), (.+)\)/.exec place.coord
    latLog = new google.maps.LatLng coordMatch[1], coordMatch[2]
    markerOptions =
      map: $scope.googleMap.map
      title: place.name
      position: latLog
      icon:
        url: "/assets/number_#{index}.png"
    place.marker = new google.maps.Marker markerOptions
    $scope.currentProject.places.push place

  savePlace = (place) ->
    Place.create {
      name: place.name
      address: place.address
      coord: place.coord
      project_id: $scope.currentProject.project.id
    }, (serverPlace) ->
      place.id = serverPlace.id

  # init
  projectReady = $d.defer()

  Project.find_by_title {title: 'last unsaved project'}, ((project) ->
    $scope.currentProject.project = project
    projectReady.resolve()
    Place.query {project_id: project.id}, (places) ->
      $scope.googleMap.mapReady.promise.then ->
        processPlace place, index for place, index in places
  ), ((reason) ->
    Project.create {title: 'last unsaved project'}, (project) ->
      $scope.currentProject.project = project
      projectReady.resolve()
  )

  if $scope.currentProject.places.length > 0
    projectReady.promise.then ->
      savePlace place for place in $scope.currentProject.places
      $scope.googleMap.mapReady.promise.then ->
        $scope.displayAllMarkers()

  # events
  $scope.$on 'projectUpdated', (event, project) ->
    $scope.currentProject.project = project
]
