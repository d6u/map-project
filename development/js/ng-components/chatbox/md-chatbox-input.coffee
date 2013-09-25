# mp-chatbox-input
app.directive 'mdChatboxInput', [->
  (scope, element, attrs) ->
    element.on 'keydown', (event) ->
      if event.keyCode == 13
        if element.val() != ''
          scope.$emit 'enterNewMessage', element.val()
          element.val ''
        return false
      return undefined
]
