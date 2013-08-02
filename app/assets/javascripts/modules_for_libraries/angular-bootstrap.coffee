app = angular.module 'angular-bootstrap', []

# tooltip
app.directive 'bsTooltip', [ ->
  (scope, element, attrs) ->

    # init
    element.tooltip({
      title: attrs.bsTooltip
      placement: attrs.bsTooltipPlacement
      container: 'body'
    })

    # events
    scope.$on '$routeChangeStart', -> element.tooltip 'destroy'
]
