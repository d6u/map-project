app.directive 'mdChatbox',
['mpTemplateCache','$compile','$timeout',
( mpTemplateCache,  $compile,  $timeout) ->

  templateUrl: '/scripts/views/_chatbox/md-chatbox.html'
  replace: true
  controllerAs: 'mdChatboxCtrl'
  controller: ['$element', '$scope', ($element, $scope) ->

    @sidemode = false

    return
  ]
  link: (scope, element, attrs, mdChatboxCtrl) ->

    # TODO: improve
    # this is used to scroll to bottom of chat historys
    scope.$watch 'projectViewCtrl.showChatbox', (newValue) ->
      if newValue
        $timeout (->
          chatHistoryBox = element.find('.md-chatbox-history')
          lastChild = chatHistoryBox.children('.md-chatbox-history-item').last()
          if lastChild.length > 0
            scrollTop = lastChild.position().top + 10 + lastChild.height() - chatHistoryBox.height()
            chatHistoryBox.animate({scrollTop: scrollTop}, 150, ->
              chatHistoryBox.perfectScrollbar 'update'
            )
        ), 300


    scope.$on 'enterNewMessage', (event, message) ->
      console.debug message
]
