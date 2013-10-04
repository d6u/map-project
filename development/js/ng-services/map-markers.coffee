app.factory 'MapMarkers',
['TheMap','MapInfoWindows','$rootScope',
( TheMap,  MapInfoWindows,  $rootScope) ->

  class MapMarkers
    constructor: ->
      # --- Properties ---
      @$searchResultsMarkers = []
      @$savedPlacesMarkers   = []


      # --- API ---
      # search results
      @addMarkerForSearchResult = (result, options={}) ->
        marker = new google.maps.Marker _.assign({
          title:     result.name
          position:  result.geometry.location
          map:       TheMap.getMap()
        }, options)
        @$searchResultsMarkers.push marker
        MapInfoWindows.bindMouseOverInfoWindowForSearchResult(marker, result)
        MapInfoWindows.bindRightClickInfoWindowForSearchResult(marker, result)
        marker


      @clearMarkersOfSearchResult = ->
        marker.setMap null for marker in @$searchResultsMarkers
        @$searchResultsMarkers = []


      # saved places
      @addMarkerForSavedPlace = (place, options={}) ->
        coordMatch = /\((.+), (.+)\)/.exec(place.coord)
        latLog     = new google.maps.LatLng(coordMatch[1], coordMatch[2])
        marker = new google.maps.Marker _.assign({
          map:      TheMap.getMap()
          title:    place.name
          position: latLog
          icon:
            url: "/img/blue-marker-3d.png"
        }, options)
        @$savedPlacesMarkers.push marker
        MapInfoWindows.bindClickInfoWindowForSavedPlace(place, marker)
        marker


      # universal
      @removeMarkers = (markers) ->
        markers = [markers] if !markers.length?
        @$searchResultsMarkers = _.difference(@$searchResultsMarkers, markers)
        @$savedPlacesMarkers   = _.difference(@$savedPlacesMarkers,   markers)


  return new MapMarkers
]
