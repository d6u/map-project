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
]
