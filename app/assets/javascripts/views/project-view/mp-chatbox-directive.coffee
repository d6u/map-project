# mp-chatbox-directive
# ========================================
app.directive 'mpChatboxDirective', ['mpTemplateCache', '$compile', '$timeout',
(mpTemplateCache, $compile, $timeout)->

  templateUrl: '/scripts/views/project-view/mp-chatbox-directive.html'
  link: (scope, element, attrs) ->

    scope.expandChatbox = ->
      element.addClass 'mp-chatbox-show'
      mpTemplateCache.get('/scripts/views/project-view/mp-chatbox-directive-expanded.html')
      .then (template) ->
        element.html $compile(template)(scope)

      # TODO: improve
      # this is used to scroll to bottom of chat historys
      $timeout (->
        chatHistoryBox = element.find('.mp-chat-history')
        lastChild = chatHistoryBox.children('.mp-chat-history-item').last()
        if lastChild.length > 0
          scrollTop = lastChild.position().top + 10 + lastChild.height() - chatHistoryBox.height()
          chatHistoryBox.animate({scrollTop: scrollTop}, 150, ->
            chatHistoryBox.perfectScrollbar 'update'
          )
      ), 300

    scope.collapseChatbox = ->
      element.removeClass 'mp-chatbox-show'
      mpTemplateCache.get('/scripts/views/project-view/mp-chatbox-directive.html')
      .then (template) ->
        element.html $compile(template)(scope)
]
