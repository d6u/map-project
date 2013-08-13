# Map Components
# ----------------------------------------
# google-map
app.directive 'googleMap', ['$window', 'TheMap', '$templateCache', '$compile',
'$timeout', 'MpProjects', '$rootScope',
($window, TheMap, $templateCache, $compile, $timeout, MpProjects) ->
  (scope, element, attrs, $rootScope) ->

    mapOptions =
      center: new google.maps.LatLng($window.userLocation.latitude, $window.userLocation.longitude)
      zoom: 8
      mapTypeId: google.maps.MapTypeId.ROADMAP
      disableDefaultUI: true

    TheMap.map = new google.maps.Map(element[0], mapOptions)

    bindInfoWindow = (place) ->
      google.maps.event.addListener place.$$marker, 'click', ->
        infoWindow = TheMap.infoWindow
        template = $templateCache.get 'marker_info_window'
        newScope = scope.$new()
        newScope.place = place
        compiled = $compile(template)(newScope)
        TheMap.infoWindow.setContent compiled[0]
        google.maps.event.clearListeners infoWindow, 'closeclick'
        google.maps.event.addListenerOnce infoWindow, 'closeclick', ->
          newScope.$destroy()
        infoWindow.open TheMap.map, place.$$marker

    # watch TheMap.searchResults
    scope.$watch ((currentScope) ->
      if TheMap.searchResults.length == TheMap.__searchResults.length && TheMap.searchResults[0] == TheMap.__searchResults[0]
        return false
      else if TheMap.searchResults.length == 0
        return null
      else
        TheMap.__searchResults = _.clone(TheMap.searchResults)
        return TheMap.searchResults
    ), ((newVal, oldVal, currentScope) ->
      if newVal == false then return

      marker.setMap(null) for marker in TheMap.markers
      TheMap.markers = []
      if newVal == null then return

      # entered new searchResults
      places = newVal
      bounds = new google.maps.LatLngBounds()
      animation = if places.length == 1 then google.maps.Animation.DROP else null
      for place in places
        markerOptions =
          map: TheMap.map
          title: place.name
          position: place.geometry.location
          animation: animation
        newPlace =
          $$marker: new google.maps.Marker markerOptions
          notes: null
          name: place.name
          address: place.formatted_address
          coord: place.geometry.location.toString()
        TheMap.markers.push newPlace.$$marker
        place.mpObject = newPlace
        bounds.extend newPlace.$$marker.getPosition()
        bindInfoWindow newPlace

      TheMap.map.fitBounds bounds
      TheMap.map.setZoom(12) if places.length < 3 && TheMap.map.getZoom() > 12
      $timeout (-> google.maps.event.trigger TheMap.markers[0], 'click'), 800
    )

    # watch for marked places and make marker for them
    scope.$watch(
      (->
        return if scope.User.checkLogin() then {attr: 'id', content: _.pluck(MpProjects.currentProject.places, 'id')} else {attr: 'order', content: _.pluck(MpProjects.currentProject.places, 'order')}
      ),
      ((newVal, oldVal) ->
        console.debug 'marker', newVal, oldVal
        _.forEach  MpProjects.currentProject.places, (place, idx) ->
          if place.$$marker
            place.$$marker.setMap null
            delete place.$$marker
          coordMatch = /\((.+), (.+)\)/.exec place.coord
          latLog = new google.maps.LatLng coordMatch[1], coordMatch[2]
          markerOptions =
            map: TheMap.map
            title: place.name
            position: latLog
            icon:
              url: "/assets/number_#{idx}.png"
          place.$$marker = new google.maps.Marker markerOptions
      ), true
    )

    # mapReady
    TheMap.mapReady.resolve()
]
