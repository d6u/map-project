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

  # Map service
  @theProject = if $routeSegment.startsWith('ot') then new TheProject() else new TheProject(Number($routeSegment.$routeParams.project_id))
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
          self.placesServiceResults = placesServiceResults[0..9]
          self.placePredictions = []
          helper.addplacesServiceResultsToMap()
      # close the drop list
      self.placePredictions = []

  # add place to saved place list
  @addPlaceToList = (place) ->
    @placesServiceResults = _.without @placesServiceResults, place
    @theProject.addPlace(place)

  @setMapCenter = (location) ->
    @googleMap.setCenter(location)

  @setMapBounds = (bounds) ->
    @googleMap.fitBounds(bounds)

  # clear search results, predicitons, search box input
  @clearSearchResults = ->
    @searchboxInput = ""
    @placePredictions = []
    helper.cleanPreviousplacesServiceResults()

  # Generate x-url-callback link for rediction to map app in iOS
  # http://maps.apple.com/?daddr=San+Francisco,+CA&saddr=cupertino
  @xUrlCallbackLink = (address) ->
    return "http://maps.apple.com/?q=#{address}"

  # Watcher
  # ----------------------------------------
  # watch for marked places and make marker for them
  $scope.$watch (=>
    return _.pluck(@theProject.places, 'id')
  ), ((newVal, oldVal) =>
    if newVal
      # re-render marker for each places
      _.forEach @theProject.places, (place, idx) =>
        # $$saved is used to hide infoWindow add place button
        place.$$saved = true
        if place.$$marker
          place.$$marker.setMap null
          delete place.$$marker
        if place.geometry
          latLog = place.geometry.location
        else
          coordMatch = /\((.+), (.+)\)/.exec place.coord
          latLog = new google.maps.LatLng coordMatch[1], coordMatch[2]
        markerOptions =
          map:      @googleMap
          title:    place.name
          position: latLog
          icon:
            url: "/img/blue-marker-3d.png"
        place.$$marker = new google.maps.Marker markerOptions
        helper.bindInfoWindow(place)

      # re-render directions if showDirections == true
      # if @showDirections
      #   renderDirections()
  ), true

  # Return
  return
]
