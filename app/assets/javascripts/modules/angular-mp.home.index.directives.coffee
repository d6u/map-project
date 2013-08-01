app = angular.module('angular-mp.home.index.directives', [])

# search box
app.directive('searchBox',
['$location',
($location) ->
  return (scope, element, attrs) ->
    scope.googleMap.searchBox = new google.maps.places.SearchBox(element[0])
])

# map canvas
app.directive('googleMap',
['$templateCache', '$timeout', '$compile',
($templateCache, $timeout, $compile) ->
  return (scope, element, attrs) ->
    cleanMarkers = ->
      marker.setMap(null) for marker in scope.googleMap.markers
      scope.googleMap.markers = []

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

    bindInfoWindow = (marker, place) ->
      google.maps.event.addListener(marker, 'click', ->
        template = $templateCache.get('marker_info_window')
        newScope = scope.$new()
        newScope.place =
          placeObj: place
          name: place.name
          address: place.formatted_address
        compiled = $compile(template)(newScope)
        scope.googleMap.infoWindow.setContent(compiled[0])
        google.maps.event.clearListeners(scope.googleMap.infoWindow, 'closeclick')
        google.maps.event.addListenerOnce(scope.googleMap.infoWindow, 'closeclick', -> newScope.$destroy())
        scope.googleMap.infoWindow.open(scope.googleMap.map, marker)
      )

    # rootScope deferred object
    scope.userLocation.then (coord) ->
      mapOptions =
        center: new google.maps.LatLng(coord.latitude, coord.longitude)
        zoom: 8
        mapTypeId: google.maps.MapTypeId.ROADMAP
        disableDefaultUI: true

      scope.googleMap.map = new google.maps.Map(element[0], mapOptions)
      google.maps.event.addListener(scope.googleMap.map, 'bounds_changed',
        -> scope.googleMap.searchBox.setBounds scope.googleMap.map.getBounds())

      scope.googleMap.infoWindow = new google.maps.InfoWindow()
      google.maps.event.addListener(scope.googleMap.searchBox, 'places_changed', searchBoxPlaceChanged)
])

app.directive('markerInfo',
['$compile', '$timeout',
($compile, $timeout) ->
  return (scope, element, attrs) ->
    scope.$apply()
])
