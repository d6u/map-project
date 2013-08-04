app = angular.module 'angular-mp.home.project-view', []


app.controller 'ProjectViewCtrl',
['$scope', 'Place', 'Project', '$location', '$rootScope', '$q', '$timeout',
 '$templateCache', '$compile', '$route',
($scope, Place, Project, $location, $rootScope, $q, $timeout,
 $templateCache, $compile, $route) ->

  # callbacks
  loadPlaceOntoMap = (dbPlace) ->
    coordMatch = /\((.+), (.+)\)/.exec dbPlace.coord
    latLog = new google.maps.LatLng coordMatch[1], coordMatch[2]
    markerOptions =
      map: $scope.googleMap.map
      title: dbPlace.name
      position: latLog
      icon:
        url: "/assets/number_#{$scope.currentProject.places.length}.png"

    place =
      marker: new google.maps.Marker markerOptions
      attrs: dbPlace
    place.attrs.order = $scope.currentProject.places.length

    $scope.currentProject.places.push place

  savePlace = (placeAtrrs) ->
    placeAtrrs.id = null
    placeAtrrs.project_id = $scope.currentProject.project.id
    Place.create placeAtrrs, (serverPlace) ->
      placeAtrrs.id = serverPlace.id

  # init
  if $scope.user.fb_access_token
    # login with unsaved places
    Project.get {project_id: $route.current.params.project_id}, (project) ->
      $scope.currentProject.project = project
      Place.query {project_id: project.id}, (places) ->
        $scope.googleMap.mapReady.promise.then ->
          loadPlaceOntoMap place for place in places

  # events
  $scope.$on 'placeAddedToList', (event, place) ->
    savePlace(place.attrs)

  $scope.$on 'placeRemovedFromList', (event, place) ->
    Place.delete {project_id: $scope.currentProject.project.id , place_id: place.attrs.id}

  $scope.$on 'projectUpdated', (event, project) ->
    $scope.currentProject.project = project
]
