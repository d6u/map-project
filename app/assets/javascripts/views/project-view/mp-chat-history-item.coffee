# mp-chat-history-item
app.directive 'mpChatHistoryItem', ['$compile', 'mpTemplateCache', '$rootScope',
($compile, mpTemplateCache, $rootScope) ->

  chooseTemplate = (type) ->
    switch type
      when 'message'
        return '/scripts/views/project-view/mp-chat-history-message.html'
      when 'userBehavior'
        return '/scripts/views/project-view/mp-chat-history-user-behavior.html'
      when 'addPlaceToList'
        return '/scripts/views/project-view/mp-chat-history-place.html'

  # return
  link: (scope, element, attrs) ->
    # if scope.chatItem.type == 'addPlaceToList' && !scope.chatItem.self
    #   scope.ActiveProject.project.one('places', scope.chatItem.placeId).get().then (place) ->
    #     scope.chatItem.placeName = place.name
    #     scope.chatItem.placeAddress = place.address
    #     $rootScope.$broadcast 'updateInPlacesList'

    mpTemplateCache.get(chooseTemplate(scope.chatItem.type)).then (template) ->
      element.html $compile(template)(scope)
      if scope.chatItem.self
        element.addClass 'mp-chat-history-self'
]
