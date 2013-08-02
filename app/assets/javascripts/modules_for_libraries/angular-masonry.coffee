app = angular.module 'angular-masonry', []

app.directive 'masonry', [ ->
  (scope, element, attrs) ->

    # init masonry
    masonryOptions =
      columnWidth: 300
      itemSelector: '.mp-project-item'
      gutter: 20
    element.masonry masonryOptions

    # update masonry when DOM changed
    scope.$watch attrs.masonry, (newValue, oldValue, scope) ->
      if newValue.length > 0
        element.masonry 'reloadItems'
        element.masonry()
]
