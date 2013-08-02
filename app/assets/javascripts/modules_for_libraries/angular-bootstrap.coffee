app = angular.module 'angular-bootstrap', []

# tooltip
app.directive 'bsTooltip', [ ->
  (scope, element, attrs) ->

    element.tooltip({
      title: attrs.bsTooltip
      placement: attrs.bsTooltipPlacement
      container: 'body'
    })
]
