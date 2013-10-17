# mp-chat-history-item


app.directive 'mdChatboxHistoryItem',
['$compile','mpTemplateCache', ($compile, mpTemplateCache) ->

  chooseTemplate = (item_type) ->
    switch item_type
      when 0 then type = 'message'
    return "/scripts/ng-components/chatbox/item-templates/mp-chat-history-#{type}.html"


  # --- Directive Obj ---
  return link: (scope, element, attrs) ->
    mpTemplateCache.get( chooseTemplate(scope.item.get('item_type')) )
    .then (template) ->
      element.html $compile(template)(scope)
]
