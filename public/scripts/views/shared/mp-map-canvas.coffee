# Map Components
# ----------------------------------------
# google-map
app.directive 'mpMapCanvas', ['$window', 'TheMap', '$compile',
'$timeout', 'MpProjects', '$rootScope', 'mpTemplateCache',
($window, TheMap, $compile, $timeout, MpProjects, $rootScope, mpTemplateCache) ->
  (scope, element, attrs) ->

    # init map
    mapOptions =
      center: new google.maps.LatLng($window.userLocation.latitude, $window.userLocation.longitude)
      zoom: 8
      mapTypeId: google.maps.MapTypeId.ROADMAP
      disableDefaultUI: true

    TheMap.map = new google.maps.Map(element[0], mapOptions)

    bindInfoWindow = (place) ->
      google.maps.event.addListener place.$$marker, 'click', ->
        mpTemplateCache.get('scripts/views/shared/marker-info.html').then (template) ->
          infoWindow = TheMap.infoWindow
          newScope = scope.$new()
          newScope.place = place
          compiled = $compile(template)(newScope)
          TheMap.infoWindow.setContent compiled[0]
          google.maps.event.clearListeners infoWindow, 'closeclick'
          google.maps.event.addListenerOnce infoWindow, 'closeclick', ->
            newScope.$destroy()
          infoWindow.open TheMap.map, place.$$marker

    # scope.addPlaceToList = (place) ->
    #   TheMap.markers = _.filter TheMap.markers, (marker) ->
    #     return true if marker.__gm_id != place.$$marker.__gm_id
    #   place.$$marker.setMap null
    #   delete place.$$marker
    #   place.id = true
    #   place.order = MpProjects.currentProject.places.length
    #   MpProjects.currentProject.places.push place

    # scope.centerPlaceInMap = (location) ->
    #   TheMap.map.setCenter location

    # scope.removePlace = (place, index) ->
    #   MpProjects.currentProject.places.splice(index, 1)[0]
    #   place.$$marker.setMap null

    # scope.displayAllMarkers = ->
    #   bounds = new google.maps.LatLngBounds()
    #   for place in MpProjects.currentProject.places
    #     bounds.extend place.$$marker.getPosition()
    #   TheMap.map.fitBounds bounds
    #   TheMap.map.setZoom 12 if MpProjects.currentProject.places.length < 3 && TheMap.map.getZoom() > 12

    # watch
    # ----------------------------------------
    # TheMap.searchResults
    scope.$watch(
      (->
        return _.pluck TheMap.searchResults, 'id'
      ),
      ((newVal, oldVal) ->
        marker.setMap(null) for marker in TheMap.markers
        TheMap.markers = []
        return if newVal.length == 0

        # entered new searchResults
        places = TheMap.searchResults
        bounds = new google.maps.LatLngBounds()
        animation = if places.length == 1 then google.maps.Animation.DROP else null
        _.forEach places, (place) ->
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
      ), true
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

    scope.$on 'mpInputboxClearInput', -> TheMap.searchResults = []
]
