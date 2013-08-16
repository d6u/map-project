# mp-headsup-messager
# ----------------------------------------
# type: (default: null), danger, success, info
app.directive 'mpHeadsupMessager', ['$rootScope', '$timeout',
($rootScope, $timeout) ->
  (scope, element, attrs) ->

    scope.message = {}
    timeoutHandle = null

    $rootScope.$on 'showHeadsupMessage', (event, message) ->
      element.removeClass 'mp-headsup-messager-show'
      $timeout.cancel timeoutHandle if timeoutHandle
      scope.message.type = if message.type then 'alert-' + message.type else null
      scope.message.title = message.title
      scope.message.content = message.content
      scope.$apply()
      element.addClass 'mp-headsup-messager-show'
      timeoutHandle = $timeout (-> element.removeClass 'mp-headsup-messager-show'), 5000

    element.find('#mp_headsup_messager_close_button').on 'click', ->
      element.removeClass 'mp-headsup-messager-show'
      $timeout.cancel timeoutHandle if timeoutHandle
]
