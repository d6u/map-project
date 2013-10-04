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
      @bindMouseOverInfoWindow = (content, marker) ->
        google.maps.event.addListener marker, 'mouseover', =>
          if !marker.$$detailInfoWindowOpen
            @$mouseOverInfoWindow.setContent(content)
            @$mouseOverInfoWindow.open TheMap.getMap(), marker
        google.maps.event.addListener marker, 'mouseout', =>
          @$mouseOverInfoWindow.close()


      @bindClickInfoWindowForSearchResult = (result, marker) ->
        mpTemplateCache.get('/scripts/ng-components/map/marker-info.html')
        .then (template) =>
          # create info window for marker
          newScope        = $rootScope.$new()
          newScope.place  = result
          infoWindow = new google.maps.InfoWindow _.assign({
            maxWidth: 320
            content:  $compile(template)(newScope)[0]
          })
          # save info window
          @$searchResultsInfoWindows.push infoWindow


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
          # mark events relates to info window
          google.maps.event.addListener infoWindow, 'closeclick', =>
            marker.$$detailInfoWindowOpen = false

          google.maps.event.addListener marker, 'click', =>
            @$mouseOverInfoWindow.close()
            for _infoWindow in @$savedPlaceInfoWindows
              _infoWindow.close()
              google.maps.event.trigger _infoWindow, 'closeclick'
            marker.$$detailInfoWindowOpen = true
            infoWindow.open TheMap.getMap(), marker

          # open info window at the first time
          google.maps.event.trigger marker, 'click'


  return new MapInfoWindows
]
