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
]
