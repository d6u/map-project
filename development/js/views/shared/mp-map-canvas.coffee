# Map Components
# ----------------------------------------
# google-map
app.directive 'mpMapCanvas',
['$window',
( $window) ->

  (scope, element, attrs) ->

    scope.TheMap.$$currentScope = scope

    # init map
    mapOptions =
      center: new google.maps.LatLng($window.userLocation.latitude, $window.userLocation.longitude)
      zoom: 8
      mapTypeId: google.maps.MapTypeId.ROADMAP
      disableDefaultUI: true

    scope.TheMap.map = new google.maps.Map(element[0], mapOptions)

    # watch for marked places and make marker for them
    scope.$watch(
      (->
        return if scope.TheProject then _.pluck(scope.TheProject.places, 'id') else undefined
      ),
      ((newVal, oldVal) ->
        if newVal
          _.forEach scope.TheProject.places, (place, idx) ->
            # $$saved is used to hide infoWindow add place button
            place.$$saved = true
            if place.$$marker
              place.$$marker.setMap null
              delete place.$$marker
            if place.geometry
              latLog = place.geometry.location
            else
              coordMatch = /\((.+), (.+)\)/.exec place.coord
              latLog = new google.maps.LatLng coordMatch[1], coordMatch[2]
            markerOptions =
              map: scope.TheMap.map
              title: place.name
              position: latLog
              icon:
                url: "/img/blue-marker-3d.png"
            place.$$marker = new google.maps.Marker markerOptions
            scope.TheMap.bindInfoWindow(place, scope)
      ), true
    )
]
