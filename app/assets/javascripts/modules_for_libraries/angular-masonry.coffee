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
    for value in attrs.masonry.split(',')
      scope.$watch value, (newValue, oldValue, scope) ->
        if element.children(masonryOptions.itemSelector).length > 0
          element.masonry 'reloadItems'
          element.masonry()
]
