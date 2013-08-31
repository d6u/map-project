# mp-map-searchbox
# ----------------------------------------
app.directive 'mpMapSearchbox', [->
  (scope, element, attrs) ->

    scope.typeaheadOptions = {
      listClass: 'cp-typeahead'
      cursorOnClass: 'cp-typeahead-cursor-on'
    }

    scope.autocompleteService = new google.maps.places.AutocompleteService()

    scope.getAutoComplete = ->
      if @searchbox.input.length > 0
        autocompleteServiceRequest = {
          bounds: scope.TheMap.map.getBounds()
          input:  scope.searchbox.input
          offset: element.getCursorPosition()
        }
        @autocompleteService.getQueryPredictions autocompleteServiceRequest,
          (predictions, serviceStatus) ->
            scope.placePredictions = predictions
      else
        @placePredictions = []

    scope.hideHomepage = ->
      if scope.interface.centerSearchBar
        scope.interface.centerSearchBar = false
        # scope.interface.showMapDrawer = true

    scope.showSearchResults = ->
      if element.val().length
        # create places services if not exist, to address the issue that
        #   mp-map-searchbox is initanciated before mp-map-canvas
        scope.placesService = new google.maps.places.PlacesService(scope.TheMap.map) if !scope.placesService

        searchRequest = {
          bounds: scope.TheMap.map.getBounds()
          query:  element.val()
        }
        scope.placesService.textSearch searchRequest, (placesResult, serviceStatus) ->
          scope.$apply -> scope.TheMap.searchResults = placesResult

        # close the drop list
        scope.placePredictions = []


    # events
    # ----------------------------------------
    # when user press enter key show search results on map
    # enter key: 13
    element.on 'keypress', (event) ->
      if event.keyCode == 13
        scope.showSearchResults()

    # Listen to event click event from typeahead menu
    scope.$on 'typeaheadListItemClicked', (event) ->
      event.stopPropagation()
      scope.showSearchResults()
]


# mpPredictionFilter
# ----------------------------------------
app.filter 'mpPredictionFilter', ->
  return (terms) ->
    values = _.pluck terms, 'value'
    return values.join(' ')
