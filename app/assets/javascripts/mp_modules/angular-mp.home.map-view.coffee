app = angular.module 'angular-mp.home.map-view', []


app.controller 'ProjectCtrl', ['$scope', 'Place', 'Project', '$location',
($scope, Place, Project, $location) ->

  # places
  $scope.places = []

  # methods
  rearrangeMarkerIcons = ->
    place.marker.setIcon({url: "/assets/number_#{index}.png"}) for place, index in $scope.places

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

  $scope.displayAllMarkers = ->
    bounds = new google.maps.LatLngBounds()
    for place in $scope.places
      bounds.extend(place.marker.getPosition())
    $scope.googleMap.map.fitBounds(bounds)
    $scope.googleMap.map.setZoom(12) if $scope.places.length < 3 && $scope.googleMap.map.getZoom() > 12

  $scope.deleteAllSavedPlaces = ->
    if confirm('Are you sure to delete all saved places? This action is irreversible.')
      place.marker.setMap(null) for place in $scope.places
      $scope.places = []

  processPlace = (place, index) ->
    coordMatch = /\((.+), (.+)\)/.exec place.coord
    latLon = new google.maps.LatLng coordMatch[1], coordMatch[2]
    markerOptions =
      map: $scope.googleMap.map
      title: place.name
      position: latLon
      icon:
        url: "/assets/number_#{index}.png"
    place.marker = new google.maps.Marker markerOptions

  # init
  $scope.$on '$routeChangeSuccess', (event, current, previous) ->
    if /\/project\/\d+/.test $location.path()
      Place.query {id: current.params.project_id}, (places) ->
        $scope.googleMap.mapReady.promise.then ->
          processPlace place, index for place, index in places
          $scope.places = places
    else
      $scope.places = []




  # events
  # $scope.$on 'loginWithNewProject', (event) ->
  #   if $scope.places.length > 0
  #     $('#new_project_modal').modal()

  # $scope.$on 'newProjectCreated', (event, project) ->
  #   for place, index in $scope.places
  #     place.object = new Place({
  #       name: place.name
  #       order: index
  #       address: place.address
  #       coord: place.marker.getPosition().toString()
  #       project_id: project.id
  #     })
  #     place.object.$save (response) -> console.log response
]



# map canvas
app.directive('googleMap',
['$templateCache', '$timeout', '$compile',
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
])

# inforwindow
app.directive('markerInfo',
['$compile', '$timeout',
($compile, $timeout) ->
  return (scope, element, attrs) ->
    scope.$apply()
])

# save marker inforwindow
app.directive('savedMarkerInfo',
[ ->
  return (scope, element, attrs) ->
    scope.$apply()
])

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

    scope.$watch 'places', (newValue, oldValue, scope) ->
      if newValue.length > 0
        scope.interface.hidePlacesList = false
        scope.interface.sideBarPlacesSlideUp = false
      else
        scope.interface.hidePlacesList = true
        scope.interface.sideBarPlacesSlideUp = true
]
