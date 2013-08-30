app.controller 'MapCtrl',
['$scope', 'TheProject', '$routeSegment', 'mpTemplateCache', '$compile',
( $scope,   TheProject,   $routeSegment,   mpTemplateCache,   $compile) ->

  # Helper methods
  self   = this # used for deep nested callbacks and inside helper
  helper = {
    cleanPreviousplacesServiceResults: ->
      for result in self.placesServiceResults
        result.$$marker.setMap null
      self.placesServiceResults = []

    addplacesServiceResultsToMap: ->
      if self.placesServiceResults.length
        places = self.placesServiceResults
        bounds = new google.maps.LatLngBounds()
        animation = if places.length == 1 then google.maps.Animation.DROP else null
        _.forEach places, (place) ->
          markerOptions =
            map:       self.googleMap
            title:     place.name
            position:  place.geometry.location
            animation: animation
          place.$$marker = new google.maps.Marker markerOptions
          place.notes    = null
          place.address  = place.formatted_address
          place.coord    = place.geometry.location.toString()
          bounds.extend place.$$marker.getPosition()
          helper.bindInfoWindow(place)

        self.googleMap.fitBounds bounds
        self.googleMap.setZoom(11) if places.length < 3

    bindInfoWindow: (place) ->
      google.maps.event.addListener place.$$marker, 'click', ->
        mpTemplateCache.get('/scripts/views/_map/marker-info.html').then (template) ->
          newScope = $scope.$new()
          newScope.place = place
          compiled = $compile(template)(newScope)
          self.infoWindow.setContent compiled[0]
          google.maps.event.clearListeners self.infoWindow, 'closeclick'
          google.maps.event.addListenerOnce self.infoWindow, 'closeclick', ->
            newScope.$destroy()
          self.infoWindow.open self.googleMap, place.$$marker
  }

  # TODO: bind to mapCtrl
  if $routeSegment.startsWith('ot')
    @theProject = new TheProject()
  else
    @theProject = new TheProject(Number($routeSegment.$routeParams.project_id))

  # Map service
  @autocompleteService  = new google.maps.places.AutocompleteService()
  @placePredictions     = []
  @placesService        = undefined # placeholder
  @placesServiceResults = []
  @infoWindow           = new google.maps.InfoWindow()

  # Map API
  # ----------------------------------------
  # show input predictions
  @getQueryPredictions = ->
    if @searchboxInput.length
      autocompleteServiceRequest = {
        bounds: self.googleMap.getBounds()
        input:  @searchboxInput
      }
      @autocompleteService.getQueryPredictions autocompleteServiceRequest, (predictions, serviceStatus) ->
        $scope.$apply ->
          self.placePredictions = predictions
    else
      @placePredictions = []

  # search places and pin on map
  @queryPlacesService = (searchTerm) ->
    @searchboxInput = searchTerm if searchTerm
    if @searchboxInput.length
      # address issue that map init after mapCtrl
      @placesService = new google.maps.places.PlacesService(@googleMap) if !@placesService

      searchRequest = {
        bounds: @googleMap.getBounds()
        query:  @searchboxInput
      }
      @placesService.textSearch searchRequest, (placesServiceResults, serviceStatus) ->
        $scope.$apply ->
          helper.cleanPreviousplacesServiceResults()
          self.placesServiceResults = placesServiceResults[1..5]
          self.placePredictions = []
          helper.addplacesServiceResultsToMap()
      # close the drop list
      self.placePredictions = []

  # Return
  return
]
