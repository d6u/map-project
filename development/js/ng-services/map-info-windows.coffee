app.factory 'MapInfoWindows',
['TheMap','$compile','mpTemplateCache','$rootScope',
( TheMap,  $compile,  mpTemplateCache,  $rootScope) ->

  class MapInfoWindows
    constructor: ->
      # --- Properties ---
      @$mouseOverInfoWindow = new google.maps.InfoWindow {disableAutoPan: true}
      @$searchResultsInfoWindows = []
      @$savedPlaceInfoWindows    = []


      # preload template
      mpTemplateCache.get('/scripts/ng-components/map/marker-info.html')


      # --- API ---
      @bindMouseOverInfoWindowForSearchResult = (marker, result) ->
        marker.addListener 'mouseover', =>
          if !marker.$$detailInfoWindowOpen
            @$mouseOverInfoWindow.setContent(result.name)
            @$mouseOverInfoWindow.open(TheMap.getMap(), marker)
        google.maps.event.addListener marker, 'mouseout', =>
          @$mouseOverInfoWindow.close()


      @bindRightClickInfoWindowForSearchResult = (marker, result) ->
        mpTemplateCache.get('/scripts/ng-components/map/marker-info.html')
        .then (template) =>
          # create info window for marker
          newScope       = $rootScope.$new()
          newScope.place = result
          infoWindow = new google.maps.InfoWindow _.assign({
            maxWidth: 320
            content:  $compile(template)(newScope)[0]
          })
          # save info window
          @$searchResultsInfoWindows.push infoWindow
          @addMarkerDeleteListener(infoWindow, marker)
          # events
          google.maps.event.addListener infoWindow, 'closeclick', =>
            marker.$$detailInfoWindowOpen = false

          google.maps.event.addListener marker, 'rightclick', =>
            @$mouseOverInfoWindow.close()
            @closeAllInfoWindow()
            marker.$$detailInfoWindowOpen = true
            infoWindow.open(TheMap.getMap(), marker)


      @bindClickInfoWindowForSavedPlace = (place, marker) ->
        mpTemplateCache.get('/scripts/ng-components/map/marker-info.html')
        .then (template) =>
          # create info window for marker
          newScope        = $rootScope.$new()
          newScope.place  = place
          infoWindow = new google.maps.InfoWindow _.assign({
            maxWidth: 320
            content:  $compile(template)(newScope)[0]
          })
          # save info window
          @$savedPlaceInfoWindows.push infoWindow
          @addMarkerDeleteListener(infoWindow, marker)
          # mark events relates to info window
          google.maps.event.addListener infoWindow, 'closeclick', =>
            marker.$$detailInfoWindowOpen = false

          google.maps.event.addListener marker, 'click', =>
            @$mouseOverInfoWindow.close()
            @closeAllInfoWindow()
            marker.$$detailInfoWindowOpen = true
            infoWindow.open(TheMap.getMap(), marker)

          # open info window at the first time
          google.maps.event.trigger marker, 'click'


      @closeAllInfoWindow = ->
        @closeInfoWindow(win) for win in @$searchResultsInfoWindows
        @closeInfoWindow(win) for win in @$savedPlaceInfoWindows


      @closeInfoWindow = (infoWindow) ->
        infoWindow.close()
        google.maps.event.trigger infoWindow, 'closeclick'


      @addMarkerDeleteListener = (infoWindow, marker) ->
        marker.addListener 'deleted', =>
          @removeInfoWindow(infoWindow)


      @removeInfoWindow = (infoWindow) ->
        @$searchResultsInfoWindows = _.without(@$searchResultsInfoWindows, infoWindow)
        @$savedPlaceInfoWindows    = _.without(@$savedPlaceInfoWindows,    infoWindow)


  # --- END MapInfoWindows ---


  return new MapInfoWindows
]
