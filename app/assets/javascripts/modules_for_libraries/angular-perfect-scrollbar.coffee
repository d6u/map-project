app = angular.module 'angular-perfect-scrollbar', []

app.directive 'perfectScrollbar', [ ->
  (scope, element, attrs) ->

    # init perfectScrollbar
    perfectScrollbarOptions =
      wheelSpeed: 30
    element.perfectScrollbar perfectScrollbarOptions

    # update perfectScrollbar
    scope.$watch attrs.perfectScrollbar, (newValue, oldValue, scope) ->
      element.perfectScrollbar 'update'
]
