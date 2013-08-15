# mp-chatbox-input
app.directive 'mpChatboxInput', ['$route', ($route) ->
  (scope, element, attrs) ->

    element.on 'keydown', (event) ->
      if event.keyCode == 13
        if element.val() != ''
          console.debug scope.participatedUsersIds, scope.chatHistory
          data =
            project_id: Number($route.current.params.project_id)
            receivers_ids: _.pluck(scope.MpChatbox.participatedUsers, 'id')
            body:
              message: element.val()
          scope.$emit 'enterNewMessage', data
          element.val ''
        return false
      return undefined
]
