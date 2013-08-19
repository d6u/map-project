angular.module('angular-masonry', [])
.directive 'mpMasonry', ['$timeout', ($timeout) ->

  scope: true
  link: (scope, element, attrs) ->

    # init masonry
    masonryOptions = {
      columnWidth: 300
      itemSelector: '.md-projects-item'
      gutter: 20
      transitionDuration: 100
    }

    $timeout((->
      scope.masonry = new Masonry(element[0], masonryOptions)
    ), 100)
]
