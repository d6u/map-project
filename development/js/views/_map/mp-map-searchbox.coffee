# mp-map-searchbox
# ----------------------------------------
app.directive 'mpMapSearchbox', [->

  controllerAs: 'mpMapSearchboxCtrl'
  controller: ['$scope', ($scope) ->

    @typeaheadOptions =
      listClass:     'cp-typeahead'
      cursorOnClass: 'cp-typeahead-cursor-on'

    @hideHomepage = ->
      if !$scope.outsideViewCtrl.hideHomepage
        $scope.outsideViewCtrl.hideHomepage = true

    return
  ]
  link: (scope, element, attrs) ->

    # events
    # ----------------------------------------
    # when user press enter key show search results on map
    # enter key: 13
    element.on 'keypress', (event) ->
      if event.keyCode == 13
        scope.mapCtrl.queryPlacesService()

    # Listen to event click event from typeahead menu
    scope.$on 'typeaheadListItemClicked', (event) ->
      event.stopPropagation()
      scope.mapCtrl.queryPlacesService()
]
