app = angular.module 'angular-mp.home.toolbar', []


# mp-control-toolbar
# ========================================
app.directive 'mpControlToolbar', [->
  templateUrl: 'mp_control_toolbar_template'
  link: (scope, element, attrs) ->


]


# Toolbar Actions
# ----------------------------------------
# mp-center-user-location
app.directive 'mpCenterUserLocation', [->
  (scope, element, attrs) ->

    getLocation = ->
      if navigator.geolocation
        navigator.geolocation.getCurrentPosition showPosition, showError
      else
        scope.$emit 'showHeadsupMessage', {type: 'danger', content: 'Geolocation is not supported by this browser.'}

    showPosition = (position) ->
      userLocation = new google.maps.LatLng(position.coords.latitude, position.coords.longitude)
      scope.TheMap.map.setCenter userLocation
      markerOptions =
        map: scope.TheMap.map
        title: 'User current location'
        position: userLocation
        animation: google.maps.Animation.DROP
        # TODO: add icon
      scope.userCurrentLocationMarker = new google.maps.Marker markerOptions
      scope.$emit 'showHeadsupMessage', {type: 'success', content: 'Marked user current location.'}

    showError = (error) ->
      switch error.code
        when error.PERMISSION_DENIED
          scope.$emit 'showHeadsupMessage', {type: 'danger', content: 'User denied the request for Geolocation.'}
        when error.POSITION_UNAVAILABLE
          scope.$emit 'showHeadsupMessage', {type: 'danger', content: 'Location information is unavailable.'}
        when error.TIMEOUT
          scope.$emit 'showHeadsupMessage', {type: 'danger', content: 'The request to get user location timed out.'}
        when error.UNKNOWN_ERROR
          scope.$emit 'showHeadsupMessage', {type: 'danger', content: 'An unknown error occurred.'}

    # events
    element.on 'click', getLocation
]


# Toolbar Inputs
# ----------------------------------------
# mp-inputbox
app.directive 'mpInputbox', ['$location', '$rootScope',
($location, $rootScope) ->
  (scope, element, attrs) ->

    scope.clearInput = (control) ->
      control.input = ''
      element.find('input').val('')
      $rootScope.$broadcast 'mpInputboxClearInput'
]


# search box
app.directive 'searchBox', ['TheMap', (TheMap) ->
  (scope, element, attrs) ->

    if scope.inMapview
      TheMap.searchBox = new google.maps.places.SearchBox(element[0])
      TheMap.searchBoxReady.resolve()
    # TODO: else
]
