# mp-chat-history-item
app.directive 'mdChatboxHistoryItem',
['$compile','mpTemplateCache', ($compile, mpTemplateCache) ->

  chooseTemplate = (type) ->
    switch type
      when 'chatMessage'
        return '/scripts/views/_chatbox/item-templates/mp-chat-history-message.html'
      when 'userBehavior'
        return '/scripts/views/_chatbox/item-templates/mp-chat-history-user-behavior.html'
      when 'addPlaceToList'
        return '/scripts/views/_chatbox/item-templates/mp-chat-history-place.html'


  return (scope, element, attrs) ->

    mpTemplateCache.get(chooseTemplate(scope.chatItem.type)).then (template) ->
      element.html $compile(template)(scope)
      if scope.chatItem.$self
        element.addClass 'mp-chat-history-self'
]
