app.controller 'MapCtrl',
['$scope','TheProject','$routeSegment','mpTemplateCache','$compile','TheMap',
class MapCtrl
  constructor: ($scope, TheProject, $routeSegment, mpTemplateCache, $compile, TheMap) ->

    # --- initialization ---
    @theProject = TheProject
    if $routeSegment.startsWith('ot')
      TheProject.initialize($scope)
    else
      TheProject.initialize($scope, Number($routeSegment.$routeParams.project_id))
]
