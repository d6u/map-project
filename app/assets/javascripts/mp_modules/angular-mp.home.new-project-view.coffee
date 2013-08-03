app = angular.module 'angular-mp.home.new-project-view', []


app.controller 'NewProjectViewCtrl',
['$scope', 'Place', 'Project', '$location', '$rootScope', '$q', '$timeout',
 '$templateCache', '$compile',
($scope, Place, Project, $location, $rootScope, $q, $timeout,
 $templateCache, $compile) ->

  # interface
  $scope.inMapview = true

  # methods
  rearrangeMarkerIcons = ->
    place.marker.setIcon({url: "/assets/number_#{index}.png"}) for place, index in $scope.currentProject.places

  $scope.addPlaceToList = (place) ->
    console.log place
    place.id = true
    place.marker.setMap(null)
    place.marker = new google.maps.Marker({
      map: $scope.googleMap.map
      title: place.name
      position: place.place.geometry.location
      icon:
        url: "/assets/number_#{$scope.currentProject.places.length}.png"
    })
    Place.create {
      name: place.name
      address: place.address
      coord: place.coord
      project_id: $scope.currentProject.project.id
    }, (serverPlace) ->
      place.id = serverPlace.id

    $scope.currentProject.places.push place

  $scope.centerPlaceInMap = (marker) ->
    marker.getMap().setCenter marker.getPosition()

  $scope.removePlace = (index, marker) ->
    marker.setMap(null)
    place = $scope.currentProject.places.splice(index, 1)[0]
    Place.delete {project_id: $scope.currentProject.project.id , place_id: place.id}
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

  searchBoxPlaceChanged = ->
    cleanMarkers()
    bounds = new google.maps.LatLngBounds()
    places = $scope.googleMap.searchBox.getPlaces()

    for place in places
      newMarker = new google.maps.Marker({
        map: $scope.googleMap.map
        title: place.name
        position: place.geometry.location
      })
      $scope.googleMap.markers.push(newMarker)
      bounds.extend(place.geometry.location)
      bindInfoWindow newMarker, place

    $scope.googleMap.map.fitBounds(bounds)
    $scope.googleMap.map.setZoom(12) if places.length < 3 && $scope.googleMap.map.getZoom() > 12
    if $scope.googleMap.markers.length == 1
      google.maps.event.trigger($scope.googleMap.markers[0], 'click')

  cleanMarkers = ->
    marker.setMap(null) for marker in $scope.googleMap.markers
    $scope.googleMap.markers = []

  bindInfoWindow = (marker, place) ->
    google.maps.event.addListener(marker, 'click', ->
      template = $templateCache.get('marker_info_window')
      newScope = $scope.$new()
      newScope.place =
        marker: marker
        place: place
        name: place.name
        address: place.formatted_address
        coord: marker.getPosition().toString()
      compiled = $compile(template)(newScope)
      $scope.googleMap.infoWindow.setContent(compiled[0])
      google.maps.event.clearListeners($scope.googleMap.infoWindow, 'closeclick')
      google.maps.event.addListenerOnce($scope.googleMap.infoWindow, 'closeclick', -> newScope.$destroy())
      $scope.googleMap.infoWindow.open($scope.googleMap.map, marker)
    )

  # db
  processPlaces = (places) ->
    $scope.currentProject.places = places
    for place, index in places
      do (place, index) ->
        coordMatch = /\((.+), (.+)\)/.exec place.coord
        latLog = new google.maps.LatLng coordMatch[1], coordMatch[2]
        markerOptions =
          map: $scope.googleMap.map
          title: place.name
          position: latLog
          icon:
            url: "/assets/number_#{index}.png"
        place.marker = new google.maps.Marker markerOptions
    $scope.googleMap.mapReady.promise.then ->
      $scope.displayAllMarkers()

  # map components
  $scope.googleMap.mapReady = $q.defer()
  $scope.googleMap.searchBoxReady = $q.defer()

  $q.all(
    [$scope.googleMap.mapReady.promise,
     $scope.googleMap.searchBoxReady.promise]
  ).then ->
    google.maps.event.addListener($scope.googleMap.searchBox, 'places_changed', searchBoxPlaceChanged)

  # init
  Project.find_by_title {title: 'last unsaved project'}, ((project) ->
    $scope.currentProject.project = project
    Place.query {project_id: project.id}, (places) ->
      processPlaces(places)
  ), ((reason) ->
    Project.create {title: 'last unsaved project'}, (project) ->
      $scope.currentProject.project = project
  )

  # events
  $scope.$on 'projectUpdated', (event, project) ->
    $scope.currentProject.project = project
]
