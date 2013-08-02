app = angular.module 'angular-mp.home.map-view', []


app.controller 'ProjectCtrl',
['$scope', 'Place', 'Project', '$location', '$rootScope', '$q',
($scope, Place, Project, $location, $rootScope, $q) ->

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
    else
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


# map canvas
app.directive 'googleMap', ['$templateCache', '$timeout', '$compile',
($templateCache, $timeout, $compile) ->
  (scope, element, attrs) ->

    searchBoxPlaceChanged = ->
      cleanMarkers()
      bounds = new google.maps.LatLngBounds()
      places = scope.googleMap.searchBox.getPlaces()

      for place in places
        newMarker = new google.maps.Marker({
          map: scope.googleMap.map
          title: place.name
          position: place.geometry.location
        })
        scope.googleMap.markers.push(newMarker)
        bounds.extend(place.geometry.location)
        bindInfoWindow newMarker, place

      scope.googleMap.map.fitBounds(bounds)
      scope.googleMap.map.setZoom(12) if places.length < 3 && scope.googleMap.map.getZoom() > 12
      if scope.googleMap.markers.length == 1
        google.maps.event.trigger(scope.googleMap.markers[0], 'click')

    cleanMarkers = ->
      marker.setMap(null) for marker in scope.googleMap.markers
      scope.googleMap.markers = []

    bindInfoWindow = (marker, place) ->
      google.maps.event.addListener(marker, 'click', ->
        template = $templateCache.get('marker_info_window')
        newScope = scope.$new()
        newScope.place =
          marker: marker
          place: place
          name: place.name
          address: place.formatted_address
          coord: marker.getPosition().toString()
        compiled = $compile(template)(newScope)
        scope.googleMap.infoWindow.setContent(compiled[0])
        google.maps.event.clearListeners(scope.googleMap.infoWindow, 'closeclick')
        google.maps.event.addListenerOnce(scope.googleMap.infoWindow, 'closeclick', -> newScope.$destroy())
        scope.googleMap.infoWindow.open(scope.googleMap.map, marker)
      )

    triggerMapResize = ->
      $timeout (->
        google.maps.event.trigger(scope.googleMap.map, 'resize')
      ), 200

    # rootScope deferred object
    scope.userLocation.then (coord) ->
      mapOptions =
        center: new google.maps.LatLng(coord.latitude, coord.longitude)
        zoom: 8
        mapTypeId: google.maps.MapTypeId.ROADMAP
        disableDefaultUI: true

      scope.googleMap.map = new google.maps.Map(element[0], mapOptions)
      scope.googleMap.mapReady.resolve()
      scope.$watch('interface.hidePlacesList', triggerMapResize)
      scope.$watch('interface.hideChatbox', triggerMapResize)
      google.maps.event.addListener(scope.googleMap.map, 'bounds_changed',
        -> scope.googleMap.searchBox.setBounds scope.googleMap.map.getBounds())

      scope.googleMap.infoWindow = new google.maps.InfoWindow()
      google.maps.event.addListener(scope.googleMap.searchBox, 'places_changed', searchBoxPlaceChanged)
]

# inforwindow
app.directive 'markerInfo', ['$compile', '$timeout',
($compile, $timeout) ->
  (scope, element, attrs) ->
    scope.$apply()
]

# save marker inforwindow
app.directive 'savedMarkerInfo', [ ->
  (scope, element, attrs) ->
    scope.$apply()
]

# sidebar place
app.directive 'sidebarPlace', ['$templateCache', '$compile',
($templateCache, $compile) ->
  (scope, element, attrs) ->

    scope.googleMap.mapReady.promise.then ->
      google.maps.event.addListener scope.place.marker, 'click', ->
        template = $templateCache.get('saved_marker_info_window')
        compiled = $compile(template)(scope)
        scope.googleMap.infoWindow.setContent(compiled[0])
        scope.googleMap.infoWindow.open(scope.place.marker.getMap(), scope.place.marker)
]


# map-sidebar-places
app.directive 'mapSidebarPlaces', [ ->
  (scope, element, attrs) ->

    scope.$watch attrs.mapSidebarPlaces, (newValue, oldValue, scope) ->
      if newValue > 0
        scope.interface.hidePlacesList = false
        scope.interface.sideBarPlacesSlideUp = false
      else
        scope.interface.hidePlacesList = true
        scope.interface.sideBarPlacesSlideUp = true

      if !scope.user.fb_access_token
        if newValue > 1
          scope.interface.showCreateAccountPromot = true

    scope.$watch 'user.fb_access_token', (newValue, oldValue, scope) ->
      if newValue
        scope.interface.showCreateAccountPromot = false
]
