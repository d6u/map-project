# mp-chat-history
app.directive 'mpChatHistory', ['MpChatbox', '$route', (MpChatbox, $route) ->
  (scope, element, attrs) ->

    project_id = Number($route.current.params.project_id)

    if !MpChatbox.rooms[project_id]
      MpChatbox.rooms[project_id] = []
    scope.chatHistory = MpChatbox.rooms[project_id]
    console.debug 'MpChatbox.rooms', MpChatbox.rooms

    # watch for changed in chat history and determine whether to scroll down to
    #   newest item
    for value in attrs.perfectScrollbar.split(',')
      scope.$watch value, (newValue, oldValue, scope) ->

        lastChild = element.children('.mp-chat-history-item').last()

        if lastChild.length > 0
          elementHeight     = element.height()
          lastChildToTop    = lastChild.position().top + 5
          lastChildToBottom = lastChildToTop - elementHeight

          if lastChildToBottom < 40
            totalHeight = element.scrollTop() + lastChildToTop + 5 + lastChild.height()
            scrollTop = totalHeight - elementHeight
            element.stop().animate {scrollTop: scrollTop}, 100, ->
              element.perfectScrollbar 'update'
]
