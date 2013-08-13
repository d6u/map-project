# mp-chatbox
# ========================================
app.directive 'mpChatbox', ['$templateCache', '$compile', 'Invitation',
'$route', 'Restangular', 'MpProjects', '$timeout',
($templateCache, $compile, Invitation, $route, Restangular, MpProjects,
 $timeout)->

  templateUrl: '/scripts/views/project_view/mp-chatbox.html'
  link: (scope, element, attrs) ->

    scope.expandChatbox = ->
      element.addClass 'mp-chatbox-show'
      template = $templateCache.get 'mp_chatbox_template_expanded'
      element.html $compile(template)(scope)

      # TODO: improve
      # this is used to scroll to bottom of chat historys
      $timeout (->
        chatHistoryBox = element.find('.mp-chat-history')
        lastChild = chatHistoryBox.children('.mp-chat-history-item').last()
        console.debug lastChild
        if lastChild.length > 0
          scrollTop = lastChild.position().top + 10 + lastChild.height() - chatHistoryBox.height()
          chatHistoryBox.animate({scrollTop: scrollTop}, 150, ->
            chatHistoryBox.perfectScrollbar 'update'
          )
      ), 300

    scope.collapseChatbox = ->
      element.removeClass 'mp-chatbox-show'
      template = $templateCache.get 'mp_chatbox_template'
      element.html $compile(template)(scope)

    # init
    # TODO: load participated users
    # console.debug MpProjects.currentProject
    scope.$watch(
      (() ->
        return MpProjects.currentProject.id
      ),
      ((newVal, oldVal) ->
        $project = Restangular.one('projects', newVal).getList('users').then (users) -> scope.participatedUsers = users
      )
    )
]
