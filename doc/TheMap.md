# TheMap service

## API

1. initialize(mapDiv[, options][, scope])

    - mapDiv: (DOM element)
    - options: (Object, optional) options to pass to google.maps.Map class
    - scope: ($scope)

2. destroy

    Do nothing yet

3. addMarkersOnMap(markers[, fitBounds])

    - markers: (Array | google.maps.Marker) with google map marker objects, could also be a marker object. The markers (or marker) will be pushed to `TheMap.$mapMarkers` array.
    - fitBounds: (Boolean) whether to fit all markers in map, default false

4. clearMarkers(markers)

    - markers: (Array | google.maps.Marker)

5. clearAllMarkers

    - return: (Array) return all markers that was removed

6. getSearchPredictions(input)

    - input: (String) string which search prediction will be based on
    - return: (Promise) resolve into an array of predictions

7. searchPlacesWith(query)

    - query: (String) search term
    - return: (Promise) places array

8. setMapCenter(latLng)

    - latLng: (google.maps.LatLng)

9. setMapBounds(bounds)

    - bounds: (google.maps.Bounds)
