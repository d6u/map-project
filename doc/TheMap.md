# TheMap service

## API

1. initialize(mapDiv[, options][, scope])

    - mapDiv: (DOM element)
    - options: (Object, optional) options to pass to google.maps.Map class
    - scope: ($scope)

    After initialization, trigger `initialized` event on the service instance

2. destroy

    Delete `$googleMap` property, then trigger `destoryed` event on the service instance.

3. addMarkersOnMap(markers[, fitBounds])

    - markers: (Array | google.maps.Marker) with google map marker objects, could also be a marker object. The markers (or marker) will be pushed to `TheMap.$mapMarkers` array.
    - fitBounds: (Boolean) whether to fit all markers in map, default false

4. clearMarkers(markers)

    - markers: (Array | google.maps.Marker)

5. clearAllMarkers

    - return: (Array) return all markers that was removed

6. setMapCenter(latLng)

    - latLng: (google.maps.LatLng)

7. setMapBounds(bounds)

    - bounds: (google.maps.Bounds)

8. getMap

    - return: (google.maps.Map) return `undefined` if no map instance

## EventEmitter

TheMap service inherited EventEmitter class methods. Usage example would be ThePlacesSearch services is using `on` to attach event listeners on TheMap service.
