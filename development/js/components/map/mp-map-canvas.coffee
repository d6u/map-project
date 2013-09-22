# Map Components
# ----------------------------------------
# google-map
app.directive 'mpMapCanvas', ['MpLocation', (MpLocation) ->

  (scope, element, attrs) ->

    location = MpLocation.getLocation()

    # init map
    mapOptions = {
      center: new google.maps.LatLng(location.latitude, location.longitude)
      zoom: 8
      mapTypeId: google.maps.MapTypeId.ROADMAP
      disableDefaultUI: true
    }

    scope.mapCtrl.googleMap = new google.maps.Map(element[0], mapOptions)
]
