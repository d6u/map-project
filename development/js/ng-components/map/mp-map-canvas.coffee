app.directive 'mpMapCanvas', ['TheMap', (TheMap) ->
  (scope, element, attrs) ->
    TheMap.initialize(element[0], undefined, scope)
]
