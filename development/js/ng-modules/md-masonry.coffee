angular.module('md-masonry', [])
.directive 'mdMasonry',
['$timeout' , ($timeout) ->
  (scope, element, attrs) ->

    setTimeout (->
      element.masonry({
        transitionDuration: 0
        itemSelector: attrs.mdMasonryItemSelector
      })
    ), 200

    # Update masonry when watcher changes
    watchList = attrs.mdMasonryWatch.split(',')
    for watchItem in watchList
      scope.$watch watchItem, ->
        setTimeout (->
          element.masonry('reloadItems')
          element.masonry()
        ), 200
]
