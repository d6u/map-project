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

    scope.clearSearchResults = ->
      element.find('input').val('')
      if scope.inMapview
        marker.setMap null for marker in scope.googleMap.markers
        scope.googleMap.markers = []
]


# search box
app.directive 'searchBox', [-> (scope, element, attrs) ->

    if scope.inMapview
      scope.googleMap.searchBox = new google.maps.places.SearchBox(element[0])
      scope.googleMap.searchBoxReady.resolve()
]


# map canvas
# ========================================
app.directive 'googleMap', ['$window', ($window) ->
  (scope, element, attrs) ->

    # rootScope deferred object
    mapOptions =
      center: new google.maps.LatLng($window.userLocation.latitude, $window.userLocation.longitude)
      zoom: 8
      mapTypeId: google.maps.MapTypeId.ROADMAP
      disableDefaultUI: true

    scope.googleMap.map = new google.maps.Map(element[0], mapOptions)
    scope.googleMap.mapReady.resolve()
]


# inforwindow
app.directive 'markerInfo', [-> (scope, element, attrs) -> scope.$apply()]


# sidebar place
app.directive 'sidebarPlace', ['$templateCache', '$compile',
($templateCache, $compile) ->
  (scope, element, attrs) ->

    google.maps.event.addListener scope.place.$$marker, 'click', ->
      template = $templateCache.get('marker_info_window')
      compiled = $compile(template)(scope)
      scope.googleMap.infoWindow.setContent(compiled[0])
      scope.googleMap.infoWindow.open(scope.place.$$marker.getMap(), scope.place.$$marker)
]


# map-sidebar-places
# ========================================
# TODO
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
        scope.interface.showPlacesList = true

    scope.editProjectDetails = ->
      $rootScope.$broadcast 'editProjectAttrs', scope.currentProject.project
]
