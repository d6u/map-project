# mp-chat-history-item
app.directive 'mpChatHistoryItem', ['$compile', '$templateCache', '$rootScope',
($compile, $templateCache, $rootScope) ->

  chooseTemplate = (type) ->
    switch type
      when 'message'
        return $templateCache.get 'chat_history_message_template'
      when 'userBehavior'
        return $templateCache.get 'chat_history_user_behavior_template'
      when 'addPlaceToList'
        return $templateCache.get 'chat_history_place_template'

  # return
  link: (scope, element, attrs) ->
    if scope.chatItem.type == 'addPlaceToList' && !scope.chatItem.self
      scope.ActiveProject.project.one('places', scope.chatItem.placeId).get().then (place) ->
        scope.chatItem.placeName = place.name
        scope.chatItem.placeAddress = place.address
        $rootScope.$broadcast 'updateInPlacesList'
    template = chooseTemplate scope.chatItem.type
    element.html $compile(template)(scope)
    if scope.chatItem.self
      element.addClass 'mp-chat-history-self'
]
