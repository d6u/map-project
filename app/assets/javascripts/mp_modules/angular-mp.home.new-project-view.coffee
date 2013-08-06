app = angular.module 'angular-mp.home.new-project-view', []


app.controller 'NewProjectViewCtrl',
['$scope', 'Project', '$location', '$rootScope', '$q', '$timeout',
 '$templateCache', '$compile',
($scope, Project, $location, $rootScope, $q, $timeout,
 $templateCache, $compile) ->

  # callbacks
  loadPlaceOntoMap = (place) ->
    coordMatch = /\((.+), (.+)\)/.exec place.coord
    latLog = new google.maps.LatLng coordMatch[1], coordMatch[2]
    markerOptions =
      map: $scope.googleMap.map
      title: place.name
      position: latLog
      icon:
        url: "/assets/number_#{place.order}.png"

    place.$$marker = new google.maps.Marker markerOptions

  savePlace = (place) ->
    place.id = null
    places = $scope.currentProject.project.all('places')
    places.post(place).then (newPlace) ->
      angular.extend place, newPlace

  # init
  if $scope.user.fb_access_token
    # login with unsaved places
    if $scope.currentProject.places.length > 0
      Project.post({title: 'last unsaved project'}).then (project) ->
        $scope.currentProject.project = project
        $rootScope.$broadcast 'editProjectAttrs', project
        savePlace place for place in $scope.currentProject.places

    # no unsaved places
    else
      projectReady = $q.defer()

      Project.find_by_title().then ((project) ->

        $scope.currentProject.project = project
        project.all('places').getList().then (places) ->
          $scope.currentProject.places = places
          $scope.googleMap.mapReady.promise.then ->
            loadPlaceOntoMap place for place in $scope.currentProject.places
      ),
      ((reason) ->

        Project.post({title: 'last unsaved project'}).then (project) ->
          $scope.currentProject.project = project
      )

  # events
  $scope.$on 'placeAddedToList', (event, place) ->
    savePlace(place)

  $scope.$on 'placeRemovedFromList', (event, place) ->
    place.$$marker = null
    place.remove()

  $scope.$on 'projectUpdated', (event, project) ->
    $scope.currentProject.project = project
    $location.path('/project/' + project.id)
]
