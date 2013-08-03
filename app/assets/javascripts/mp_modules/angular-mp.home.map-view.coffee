app = angular.module 'angular-mp.home.map-view', []


app.controller 'ProjectCtrl',
['$scope', 'Place', 'Project', '$location', '$rootScope', '$q', '$timeout',
($scope, Place, Project, $location, $rootScope, $q, $timeout) ->

  # navbar button
  $scope.inMapView = true

  # places
  $scope.currentProject =
    project: {}
    places: []

  # methods
  rearrangeMarkerIcons = ->
    place.marker.setIcon({url: "/assets/number_#{index}.png"}) for place, index in $scope.currentProject.places

  $scope.addPlaceToList = (place) ->
    place.marker.setMap(null)
    place.marker = new google.maps.Marker({
      map: $scope.googleMap.map
      title: place.name
      position: place.place.geometry.location
      icon:
        url: "/assets/number_#{$scope.currentProject.places.length}.png"
    })
    if $scope.currentProject.project.id
      placeSimple =
        name: place.name
        notes: place.notes
        address: place.address
        coord: place.coord
        order: $scope.currentProject.places.length
        project_id: $scope.currentProject.project.id
      Place.save placeSimple, (response) ->
        place.project_id = response.project_id
        place.id = response.id
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

  # init
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

  $scope.$on '$routeChangeSuccess', (event, current, previous) ->
    if /\/project\/\d+/.test $location.path()
      Project.get {project_id: current.params.project_id}, (project) ->
        $scope.currentProject.project = project
      Place.query {id: current.params.project_id}, (places) ->
        $scope.googleMap.mapReady.promise.then ->
          processPlace place, index for place, index in places
          $scope.currentProject.places = places
          $timeout $scope.displayAllMarkers, 200 if places.length > 0
    else
      if $scope.user.fb_access_token
        $rootScope.$broadcast 'newProject'
      $scope.currentProject.places = []

  # events
  $scope.$on 'fbLoggedIn', ->
    if $location.path() == '/new_project' && $scope.currentProject.places.length > 0
      $rootScope.$broadcast 'newProject'

  $scope.$on 'fbNotLoggedIn', ->
    $scope.currentProject =
      project: {}
      places: []

  $scope.$on 'newProjectCreated', (event, project) ->
    $scope.currentProject.project = project
    $scope.projects.unshift project
    allPlacesSaved = []
    for place, index in $scope.currentProject.places
      do (place, index) ->
        place.order = index
        place.project_id = project.id
        placeSimple =
          name: place.name
          notes: place.notes
          address: place.address
          coord: place.coord
          order: index
          project_id: place.project_id
        placeSaved = $q.defer()
        allPlacesSaved.push placeSaved.promise
        Place.save placeSimple, (response) ->
          place.id = response.id
          placeSaved.resolve()
    $scope.interface.showCreateAccountPromot = false
    $q.all(allPlacesSaved).then ->
      $location.path '/project/' + project.id
]
