# mp-chatbox-directive
# ========================================
app.directive 'mpChatboxDirective',
['mpTemplateCache','$compile','$timeout',
( mpTemplateCache,  $compile,  $timeout) ->

  templateUrl: '/scripts/views/in/project/md-chatbox.html'
  controllerAs: 'mdChatboxCtrl'
  controller: ['$element', '$scope', ($element, $scope) ->

    @chatboxExpanded = false

    @expandChatbox = ->
      $element.addClass 'mp-chatbox-show'
      @chatboxExpanded = true

      # TODO: improve
      # this is used to scroll to bottom of chat historys
      $timeout (->
        chatHistoryBox = $element.find('.mp-chat-history')
        lastChild = chatHistoryBox.children('.mp-chat-history-item').last()
        if lastChild.length > 0
          scrollTop = lastChild.position().top + 10 + lastChild.height() - chatHistoryBox.height()
          chatHistoryBox.animate({scrollTop: scrollTop}, 150, ->
            chatHistoryBox.perfectScrollbar 'update'
          )
      ), 300

    @collapseChatbox = ->
      $element.removeClass 'mp-chatbox-show'
      @chatboxExpanded = false


    return
  ]
  link: (scope, element, attrs, mdChatboxCtrl) ->

    scope.$on 'enterNewMessage', (event, message) ->
      scope.insideViewCtrl.MpChatbox.sendChatMessage(message, scope.mapCtrl.theProject)
]
