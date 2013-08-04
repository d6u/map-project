app = angular.module 'angular-mp.home.new-project-view', []


app.controller 'NewProjectViewCtrl',
['$scope', 'Place', 'Project', '$location', '$rootScope', '$q', '$timeout',
 '$templateCache', '$compile',
($scope, Place, Project, $location, $rootScope, $q, $timeout,
 $templateCache, $compile) ->

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
    if $scope.currentProject.places.length > 0
      Project.create {title: 'last unsaved project'}, (project) ->
        $scope.currentProject.project = project
        $rootScope.$broadcast 'editProjectAttrs', project
        savePlace place.attrs for place in $scope.currentProject.places
    # no unsaved places
    else
      projectReady = $q.defer()

      Project.find_by_title {title: 'last unsaved project'},
      ((project) ->

        $scope.currentProject.project = project
        Place.query {project_id: project.id}, (places) ->
          $scope.googleMap.mapReady.promise.then ->
            loadPlaceOntoMap place for place in places
      ),
      ((reason) ->

        Project.create {title: 'last unsaved project'}, (project) ->
          $scope.currentProject.project = project
      )

  # events
  $scope.$on 'placeAddedToList', (event, place) ->
    savePlace(place.attrs)

  $scope.$on 'placeRemovedFromList', (event, place) ->
    Place.delete {project_id: $scope.currentProject.project.id , place_id: place.attrs.id}

  $scope.$on 'projectUpdated', (event, project) ->
    $scope.currentProject.project = project
]
