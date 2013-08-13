app = angular.module 'angular-bootstrap', []


# bs-tooltip, bs-tooltip-placement
app.directive 'bsTooltip', ['$timeout', ($timeout) ->
  (scope, element, attrs) ->

    # init

    $timeout -> element.tooltip({
      animation: false
      title: attrs.bsTooltip
      placement: attrs.bsTooltipPlacement
      container: 'body'
    })

    # events
    # destory tooltip when route change, otherwise tooltip may stay forever
    scope.$on '$routeChangeStart', -> element.tooltip 'destroy'
]
