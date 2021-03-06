# mini-map-cover
app.directive 'miniMapCover', ['MpLocation', (MpLocation) ->

  scope: true
  link: (scope, element, attrs) ->

    userLocation = MpLocation.getLocation()

    # TODO: user location error fall back
    mapOptions =
      center: new google.maps.LatLng(userLocation.latitude, userLocation.longitude)
      zoom: 12
      mapTypeId: google.maps.MapTypeId.ROADMAP
      disableDefaultUI: true
      disableDoubleClickZoom: true
      draggable: false
      scrollwheel: false

    scope.miniMap = new google.maps.Map(element[0], mapOptions)

    if scope.project.get('places')?.length > 0
      bounds = new google.maps.LatLngBounds()
      for place in scope.project.get('places')
        coordMatch = /\((.+), (.+)\)/.exec(place.coord)
        latLog = new google.maps.LatLng(coordMatch[1], coordMatch[2])
        markerOptions =
          map: scope.miniMap
          position: latLog
          cursor: 'default'
        marker = new google.maps.Marker markerOptions
        bounds.extend(marker.getPosition())
      scope.miniMap.fitBounds(bounds)
]
