app.directive 'mpMapDrawer', ['TheMap', '$rootScope', 'MpProjects', '$timeout',
(TheMap, $rootScope, MpProjects, $timeout) ->

  templateUrl: '/scripts/views/shared/mp-map-drawer.html'
  scope: true
  link: (scope, element, attrs) ->

    scope.interface.showMapDrawer = false

    scope.clearInput = (control) ->
      scope.searchbox.input = ''
      element.find('input').val('')
      $rootScope.$broadcast 'mpInputboxClearInput'

    scope.fbLogin = ->
      $rootScope.User.login ->
        return if MpProjects.currentProject.places.length > 0 then '/new_project' else '/all_projects'

    # watcher
    scope.$watch 'searchbox.input.length', (newVal) ->
      if newVal > 0
        scope.interface.showMapDrawer = true

    scope.$watch 'interface.showMapDrawer', (newVal) ->
      $timeout (-> google.maps.event.trigger(TheMap.map, 'resize')), 300
]