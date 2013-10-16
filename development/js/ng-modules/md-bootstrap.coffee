
angular.module('angular-bootstrap', [])


# --- Tooltip ---
# bs-tooltip, bs-tooltip-placement
.directive('bsTooltip', ['$timeout', ($timeout) ->
  (scope, element, attrs) ->

    initTooltip = ->
      element.tooltip({
        animation: false
        title:     attrs.bsTooltip
        placement: attrs.bsTooltipPlacement
        container: 'body'
      })

    # init
    initTooltip()

    # events
    # destory tooltip when route change, otherwise tooltip may stay forever
    scope.$on '$routeChangeStart', ->
      element.tooltip 'destroy'
      initTooltip()
])


# --- Popover ---
# bs-popover
# bs-popover-placement
# bs-popover-content: will be evaluated on current scope
.directive('bsPopover', ['$timeout', ($timeout) ->
  (scope, element, attrs) ->

    initPopover = ->
      element.popover({
        html:      true
        placement: attrs.bsPopoverPlacement
        container: 'body'
        title:     attrs.bsPopover
        content:   scope.$eval(attrs.bsPopoverContent)
      })

    # init
    initPopover()

    # events
    # destory popover when route change, same reason as tooltip
    scope.$on '$routeChangeStart', ->
      element.popover('destroy')
      initPopover()
])
