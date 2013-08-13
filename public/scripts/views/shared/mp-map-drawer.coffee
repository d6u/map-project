app.directive 'mpMapDrawer', ['TheMap', '$rootScope',
(TheMap, $rootScope) ->

  templateUrl: '/scripts/views/shared/mp-map-drawer.html'
  scope: true
  link: (scope, element, attrs) ->

    scope.interface.showMapDrawer = false

    scope.clearInput = (control) ->
      scope.searchbox.input = ''
      element.find('input').val('')
      $rootScope.$broadcast 'mpInputboxClearInput'
      scope.interface.showMapDrawer = false

    # watcher
    scope.$watch 'searchbox.input.length', (newVal) ->
      if newVal > 0
        scope.interface.showMapDrawer = true
]