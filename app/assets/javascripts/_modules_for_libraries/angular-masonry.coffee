angular.module('angular-masonry', [])
.directive 'mpMasonry', ['$timeout', ($timeout) ->
  scope: true
  link: (scope, element, attrs) ->

    # init masonry
    masonryOptions =
      columnWidth: 300
      itemSelector: '.mp-project-item'
      gutter: 20
      transitionDuration: 0

    scope.masonry = new Masonry(element[0], masonryOptions)

    # update masonry when DOM changed
    for value in attrs.mpMasonry.split(',')
      scope.$watch value, (newValue, oldValue, scope) ->
        if element.children(masonryOptions.itemSelector).length > 0
          $timeout (->
            scope.masonry.reloadItems()
          ), 200
]
