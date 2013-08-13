app = angular.module 'angular-masonry', []

app.directive 'mpMasonry', ['$timeout', ($timeout) ->
  (scope, element, attrs) ->

    # init masonry
    masonryOptions =
      columnWidth: 300
      itemSelector: '.mp-project-item'
      gutter: 20
      transitionDuration: 0
    element.masonry masonryOptions

    # update masonry when DOM changed
    for value in attrs.mpMasonry.split(',')
      scope.$watch value, (newValue, oldValue, scope) ->
        if element.children(masonryOptions.itemSelector).length > 0
          $timeout (->
            element.masonry 'reloadItems'
            element.masonry()
          ), 200
]
