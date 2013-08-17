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
          input: scope.searchbox.input
          offset: element.getCursorPosition()
        }
        @autocompleteService.getPlacePredictions autocompleteServiceRequest,
          (predictions, serviceStatus) ->
            # console.debug 'predictions', predictions, serviceStatus
            scope.placePredictions = predictions
      else
        scope.placePredictions = []
      element.siblings('.cp-typeahead').css({
        left: element.position().left
      })

    # enable drop down list selection using keyboard
    #   down arrow: 40
    #   up arrow:   38
    # TODO: improve
    element.on 'keydown', (event) ->
      if event.keyCode == 40
        typeahead = element.siblings('.cp-typeahead')
        target = typeahead.children('.cp-typeahead-cursor-on')
        if target.length != 0
          target.removeClass 'cp-typeahead-cursor-on'
          if target.next().length != 0
            target.next().addClass 'cp-typeahead-cursor-on'
          else
            typeahead.children().first().addClass 'cp-typeahead-cursor-on'
        else
          typeahead.children().first().addClass 'cp-typeahead-cursor-on'
        match = /[\s\n]*(\w[\s\w]*\w)[\s\n]*/g.exec(typeahead.children('.cp-typeahead-cursor-on').html())[1]
        element.val match if match
        return false
      else if event.keyCode == 38
        typeahead = element.siblings('.cp-typeahead')
        target = typeahead.children('.cp-typeahead-cursor-on')
        if target.length != 0
          target.removeClass 'cp-typeahead-cursor-on'
          if target.prev().length != 0
            target.prev().addClass 'cp-typeahead-cursor-on'
          else
            typeahead.children().last().addClass 'cp-typeahead-cursor-on'
        else
          typeahead.children().last().addClass 'cp-typeahead-cursor-on'
        match = /[\s\n]*(\w[\s\w]*\w)[\s\n]*/g.exec(typeahead.children('.cp-typeahead-cursor-on').html())[1]
        element.val match if match
        return false







    # scope.TheMap.searchBox = new google.maps.places.SearchBox(element[0])

    scope.hideHomepage = ->
      if scope.interface.centerSearchBar
        scope.interface.centerSearchBar = false
        # scope.interface.showMapDrawer = true

    # events
    # ----------------------------------------
    # scope.$watch 'searchbox.input', (newVal) ->
    #   if newVal && newVal.length > 0
    #     console.debug()
    #   else
    #     console.debug()
        # scope.interface.showMapDrawer = true

    # the first time attaching this listener, event will trigger once
    # google.maps.event.addListener scope.TheMap.map, 'bounds_changed', ->
    #   scope.TheMap.searchBox.setBounds scope.TheMap.map.getBounds()

    # google.maps.event.addListener scope.TheMap.searchBox, 'places_changed', ->
    #   scope.$apply -> scope.TheMap.searchResults = scope.TheMap.searchBox.getPlaces()
]


# mpPredictionFilter
app.filter 'mpPredictionFilter', ->
  return (terms) ->
    result = ""
    for term in terms
      result += term.value
      result += ' '
    return result
