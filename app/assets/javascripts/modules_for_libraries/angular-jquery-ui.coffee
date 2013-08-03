app = angular.module 'angular-jquery-ui', []

app.directive 'jqueryUiSortable', [ ->
  (scope, element, attrs) ->

    # event funcions
    updateFn = (event, ui) ->
      scope.$apply ->
        newPlaces = []
        element.children('.mp-sidebar-place').each (index) ->
          childScope = $(this).scope()
          childScope.place.marker.setIcon({url: "/assets/number_#{index}.png"})
          newPlaces.push childScope.place
        scope.currentProject.places = newPlaces

    # init
    sortableOptions =
      appendTo: document.body
      helper:   'clone'
      cursor:   'move'
      distance: 5
      handle:   '.mp-place-marker-icon'
      update:   updateFn
    element.sortable(sortableOptions)
]
