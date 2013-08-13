# List Components
# ----------------------------------------
# mp-places-list
app.directive 'mpPlacesList', ['$window', '$rootScope',
($window, $rootScope) ->

  templateUrl: 'scripts/views/shared/mp-places-list.html'
  link: (scope, element, attrs) ->

    hideListAccordingly = ->
      listEmpty = scope.MpProjects.currentProject && scope.MpProjects.currentProject.places && scope.MpProjects.currentProject.places.length == 0 && scope.TheMap.searchResults.length == 0
      if listEmpty then element.addClass 'hide' else element.removeClass 'hide'

    scope.$watch 'MpProjects.currentProject.places.length', (newVal, oldVal, scope) ->
      hideListAccordingly()

    scope.$watch 'TheMap.searchResults.length', (newVal, oldVal, scope) ->
      hideListAccordingly()

    scope.showEditProjectModal = (project) ->
      $rootScope.$broadcast 'showBottomModalbox', {type: 'editProject', project: project}

    $($window).on 'resize', ->
      element.css {maxHeight: $($window).height() - 112 - 20}
    $($window).trigger 'resize'

    element.perfectScrollbar({
      wheelSpeed: 20
      wheelPropagation: true
      })

    scope.$watch 'MpProjects.currentProject.places.length', (newVal, oldVal) ->
      # TODO: scroll to places list last (newest) item
      element.scrollTop 0
      element.perfectScrollbar 'update'

    scope.$watch 'TheMap.searchResults.length', (newVal, oldVal) ->
      # TODO: scroll to search result position
      # TODO: not only update according to length
      element.scrollTop 0
      element.perfectScrollbar 'update'
]
