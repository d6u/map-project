app.directive 'mpMapDrawer', ['$rootScope', '$timeout',
($rootScope, $timeout) ->

  templateUrl: '/scripts/views/shared/mp-map-drawer.html'
  scope: true
  link: (scope, element, attrs) ->

    scope.interface.showMapDrawer = false

    scope.clearInput = (control) ->
      scope.searchbox.input = ''
      element.find('input').val('')
      scope.TheMap.searchResults = []

    scope.fbLogin = ->
      $rootScope.MpUser.login ->
        return if scope.MpProjects.currentProjectPlaces.length > 0 then '/new_project' else '/all_projects'

    scope.showProjectAddFriendsModal = ->
      $rootScope.$broadcast 'showProjectAddFriendsModal', {name: 'test'}

    # watcher
    scope.$watch 'searchbox.input.length', (newVal) ->
      if newVal > 0
        scope.interface.showMapDrawer = true

    scope.$watch 'interface.showMapDrawer', (newVal) ->
      $timeout (-> google.maps.event.trigger(scope.TheMap.map, 'resize')), 300
]