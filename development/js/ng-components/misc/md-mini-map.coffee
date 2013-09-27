app.directive 'mdMiniMap', [->

  controller: [class MdMiniMapCtrl
    constructor: ->
  ]
  link: (scope, element, attrs, MdMiniMapCtrl) ->
    mapOptions =
      center: new google.maps.LatLng(36.1000, -112.1000)
      zoom: 12
      mapTypeId: google.maps.MapTypeId.ROADMAP
      disableDefaultUI: true
      disableDoubleClickZoom: true
      draggable: false
      scrollwheel: false

    MdMiniMapCtrl.miniMap = new google.maps.Map(element[0], mapOptions)

    coordinates = scope.$eval(attrs.mdMiniMap)
    if coordinates.length
      bounds = new google.maps.LatLngBounds()
      for coord in coordinates
        matches = /\((.+), (.+)\)/.exec(coord)
        latLog  = new google.maps.LatLng(matches[1], matches[2])
        markerOptions =
          map: MdMiniMapCtrl.miniMap
          position: latLog
          cursor: 'default'
        marker = new google.maps.Marker markerOptions
        bounds.extend(marker.getPosition())
      MdMiniMapCtrl.miniMap.fitBounds(bounds)
]
