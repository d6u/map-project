app.directive 'mdChatboxHistory',
[->

  controllerAs: 'mdChatboxHistoryCtrl'
  controller: [->

    @chatHistory = []

    # project_id = Number($route.current.params.project_id)

    # if !MpChatbox.rooms[project_id]
    #   MpChatbox.rooms[project_id] = []
    # @chatHistory = MpChatbox.rooms[project_id]


    return
  ]
  link: (scope, element, attrs, mdChatboxHistoryCtrl) ->

    # watch for changed in chat history and determine whether to scroll down to
    #   newest item
    for value in attrs.perfectScrollbar.split(',')
      scope.$watch value, ->
        lastChild = element.children('.md-chatbox-history-item').last()

        if lastChild.length > 0
          elementHeight     = element.height()
          lastChildToTop    = lastChild.position().top + 5
          lastChildToBottom = lastChildToTop - elementHeight

          if lastChildToBottom < 40
            totalHeight = element.scrollTop() + lastChildToTop + 5 + lastChild.height()
            scrollTop = totalHeight - elementHeight + 100 # TODO: improve
            element.stop().animate {scrollTop: scrollTop}, 100, ->
              element.perfectScrollbar 'update'
]
