app = angular.module 'angular-perfect-scrollbar', []

app.directive 'perfectScrollbar', ['$window', ($window) ->
  (scope, element, attrs) ->

    # init perfectScrollbar
    perfectScrollbarOptions =
      wheelSpeed: 30
    element.perfectScrollbar perfectScrollbarOptions

    # watch for window resize
    $($window).on 'resize', ->
      element.perfectScrollbar 'update'

    # update perfectScrollbar
    for value in attrs.perfectScrollbar.split(',')
      scope.$watch value, (newValue, oldValue, scope) ->
        element.perfectScrollbar 'update'
]
