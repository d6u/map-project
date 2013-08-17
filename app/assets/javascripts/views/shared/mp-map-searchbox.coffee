# get cursor position of a input
(($) ->
  $.fn.getCursorPosition = ->
    input = this.get(0)
    if !input then return # // No (input) element found
    if 'selectionStart' in input
      # // Standard-compliant browsers
      return input.selectionStart
    else if document.selection
      # // IE
      input.focus()
      sel = document.selection.createRange()
      selLen = document.selection.createRange().text.length
      sel.moveStart('character', -input.value.length)
      return sel.text.length - selLen
)(jQuery)


# mp-map-searchbox
# ----------------------------------------
app.directive 'mpMapSearchbox', [->
  (scope, element, attrs) ->

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
      element.siblings('.cp-typeahead').css({left: element.position().left})

    # enable drop down list selection using keyboard
    #   down arrow: 40
    #   up arrow:   38
    element.on 'keydown', (event) ->
      if element.val().length && (event.keyCode == 40 || event.keyCode == 38)
        dropList = element.siblings('.cp-typeahead')
        if dropList.children().length
          dropDownWithDownArrow = event.keyCode == 40 && !dropList.hasClass('cp-typeahead-dropup')
          dropDownWithUpArrow   = event.keyCode == 38 && !dropList.hasClass('cp-typeahead-dropup')
          dropUpWithDownArrow   = event.keyCode == 40 && dropList.hasClass('cp-typeahead-dropup')
          dropUpWithUpArrow     = event.keyCode == 38 && dropList.hasClass('cp-typeahead-dropup')
          cursor = dropList.children('.cp-typeahead-cursor-on')
          if dropDownWithDownArrow || dropUpWithUpArrow
            if cursor.length
              cursor.removeClass('cp-typeahead-cursor-on')
              if cursor.next().length
                cursor.next().addClass('cp-typeahead-cursor-on')
              else
                dropList.children().first().addClass('cp-typeahead-cursor-on')
            else
              dropList.children().first().addClass('cp-typeahead-cursor-on')
          else # dropDownWithUpArrow && dropUpWithDownArrow
            if cursor.length
              cursor.removeClass('cp-typeahead-cursor-on')
              if cursor.prev().length
                cursor.prev().addClass('cp-typeahead-cursor-on')
              else
                dropList.children().last().addClass('cp-typeahead-cursor-on')
            else
              dropList.children().lastt().addClass('cp-typeahead-cursor-on')
          # put selection text into input box
          element.val dropList.children('.cp-typeahead-cursor-on').html()
          return false

    scope.hideHomepage = ->
      if scope.interface.centerSearchBar
        scope.interface.centerSearchBar = false
        # scope.interface.showMapDrawer = true


    # events
    # ----------------------------------------
    # when user press enter key show search results on map
    # enter key: 13
    element.on 'keypress', (event) ->
      if event.keyCode == 13 && element.val().length
        # create places services if not exist, to address the issue that
        #   mp-map-searchbox is initanciated before mp-map-canvas
        scope.placesService = new google.maps.places.PlacesService(scope.TheMap.map) if !scope.placesService

        searchRequest = {
          bounds: scope.TheMap.map.getBounds()
          query:  element.val()
        }
        scope.placesService.textSearch searchRequest, (placesResult, serviceStatus) ->
          # console.debug 'placesService', placesResult
          scope.$apply -> scope.TheMap.searchResults = placesResult

        # close the drop list
        scope.placePredictions = []
]


# mpPredictionFilter
# ----------------------------------------
app.filter 'mpPredictionFilter', ->
  return (terms) ->
    values = _.pluck terms, 'value'
    return values.join(' ')
