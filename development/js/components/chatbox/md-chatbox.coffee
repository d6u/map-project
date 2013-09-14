app.directive 'mdChatbox',
['mpTemplateCache','$compile','$timeout','MpChat',
( mpTemplateCache,  $compile,  $timeout,  MpChat) ->

  templateUrl: '/scripts/components/chatbox/md-chatbox.html'
  replace: true
  controllerAs: 'mdChatboxCtrl'
  controller: ['$element', '$scope', 'TheProject', class MdChatboxCtrl

    contructor: ($element, $scope, TheProject) ->

      @sidemode = false
      @MpChat   = MpChat

      MpChat.initialize($scope)

      @showPlaceOnMap = (place) ->
        $scope.drawerCtrl.showPlaceOnMap(_.find(TheProject.places, {id: place.id}))
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

    # Send message to server
    scope.$on 'enterNewMessage', (event, message) ->
      MpChat.sendChatMessage(message)
]
