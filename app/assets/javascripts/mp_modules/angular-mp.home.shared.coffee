app = angular.module 'angular-mp.home.shared', []


# mp-navbar-top-secion
# ========================================
app.directive 'mpNavbarTopSecion', [->
  templateUrl: 'mp_navbar_top_template'
  link: (scope, element, attrs) ->
]


# dropdonw menu
app.directive 'navbarDropdownMenu',[->
  templateUrl: 'navbar_dropdown_menu'
  link: (scope, element, attrs) ->
]


# mp-navbar-inputs-section
app.directive 'mpNavbarInputsSection', [->
  templateUrl: 'mp_navbar_inputs_section_template'
  link: (scope, element, attrs) ->
]


# search box
app.directive 'searchBox', [->
  (scope, element, attrs) ->

    scope.googleMap.searchBox = new google.maps.places.SearchBox(element[0])

    scope.clearSearchResults = ->
      element.val('')
      if scope.inMapview
        marker.setMap(null) for marker in scope.googleMap.markers
        scope.googleMap.markers = []
]


# map canvas
# ========================================
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
      # scope.googleMap.mapReady.resolve()
      scope.$watch('interface.showPlacesList', triggerMapResize)
      scope.$watch('interface.showChatbox', triggerMapResize)
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


# sidebar place
app.directive 'sidebarPlace', ['$templateCache', '$compile',
($templateCache, $compile) ->
  (scope, element, attrs) ->

    google.maps.event.addListener scope.place.marker, 'click', ->
      template = $templateCache.get('marker_info_window')
      compiled = $compile(template)(scope)
      scope.googleMap.infoWindow.setContent(compiled[0])
      scope.googleMap.infoWindow.open(scope.place.marker.getMap(), scope.place.marker)
]


# map-sidebar-places
# ========================================
app.directive 'mapSidebarPlaces', ['$timeout', '$rootScope',
($timeout, $rootScope) ->
  templateUrl: 'mp_sidebar_places_template'
  link: (scope, element, attrs) ->

    scope.$watch attrs.mapSidebarPlaces, (newValue, oldValue, scope) ->
      if !scope.user.id
        if newValue > 0
          scope.interface.showPlacesList = true
          scope.interface.sideBarPlacesSlideUp = false
        else
          scope.interface.showPlacesList = false
          scope.interface.sideBarPlacesSlideUp = true

        if newValue > 1
          scope.interface.showCreateAccountPromot = true

    scope.$watch 'user.id', (newValue, oldValue, scope) ->
      if newValue
        scope.interface.showCreateAccountPromot = false

    scope.$on '$routeChangeSuccess', (event, current, previous) ->
      if current.params.project_id
        scope.interface.showPlacesList = false
        scope.interface.sideBarPlacesSlideUp = true

    scope.editProjectDetails = ->
      $rootScope.$broadcast 'editProjectDetails', scope.currentProject.project
]
