app.factory 'MpLocation', ['$q', ($q) ->

  userLocation = {
    latitude:   36.1000
    longitude: -112.1000
  }

  MpLocation = {
    getLocation: ->
      userLocation
  }

  $q.when(ipLocationChecked).then (location) ->
    if !location.error
      userLocation.latitude  = location.geoplugin_latitude
      userLocation.longitude = location.geoplugin_longitude

  return MpLocation
]
