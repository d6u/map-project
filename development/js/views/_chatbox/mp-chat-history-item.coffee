# mp-chat-history-item
app.directive 'mpChatHistoryItem', ['$compile', 'mpTemplateCache', '$rootScope',
($compile, mpTemplateCache, $rootScope) ->

  chooseTemplate = (type) ->
    switch type
      when 'chatMessage'
        return '/scripts/views/in/project/mp-chat-history-message.html'
      when 'userBehavior'
        return '/scripts/views/in/project/mp-chat-history-user-behavior.html'
      when 'addPlaceToList'
        return '/scripts/views/in/project/mp-chat-history-place.html'

  # return
  link: (scope, element, attrs) ->

    mpTemplateCache.get(chooseTemplate(scope.chatItem.type)).then (template) ->
      element.html $compile(template)(scope)
      if scope.chatItem.self
        element.addClass 'mp-chat-history-self'
]
