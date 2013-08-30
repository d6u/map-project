app.controller 'PlacelistCtrl',
['$scope', '$timeout',
( $scope,   $timeout)->

  # placelistCtrl
  @showPlaceOnMap = (place) ->
    $scope.mapCtrl.setMapCenter(place.$$marker.getPosition())
    google.maps.event.trigger(place.$$marker, 'click')
    $scope.outsideViewCtrl.workplaceScrollup = false

  @displayAllMarkers = ->
    bounds = new google.maps.LatLngBounds()
    for place in $scope.mapCtrl.theProject.places
      bounds.extend place.$$marker.getPosition()
    $scope.mapCtrl.setMapBounds(bounds)
    $scope.outsideViewCtrl.workplaceScrollup = false

  @focusSearchboxInput = ->
    $scope.outsideViewCtrl.workplaceScrollup = false
    $('[md-searchbox-input-m]').focus()
    # Fix manual focus document not scrollup issue on ios
    $timeout (->
      $(window).scrollTop(1000)
    ), 400

  @showEditProjectDetailForm = ->
    $('[md-edit-project]').addClass('md-show')

  # Return
  return
]
