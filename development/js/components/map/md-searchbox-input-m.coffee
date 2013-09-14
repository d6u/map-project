app.directive 'mdSearchboxInputM',
[->
  (scope, element, attrs) ->

    element.on 'keyup', (event) ->
      if event.keyCode == 13
        scope.mapCtrl.queryPlacesService()
        element.blur()
]
