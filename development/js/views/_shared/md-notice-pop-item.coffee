app.directive 'mdNoticePopItem',
['mpTemplateCache', '$compile', (mpTemplateCache, $compile) ->

  (scope, element, attrs) ->

    switch scope.notice.type
      when 'addFriendRequest'
        templateUrl = '/scripts/views/_shared/notice-pop-templates/add-friend-request.html'
      when 'addFriendRequestAccepted'
        templateUrl = '/scripts/views/_shared/notice-pop-templates/add-friend-request-accepted.html'
      when 'projectInvitation'
        templateUrl = '/scripts/views/_shared/notice-pop-templates/project-invitation.html'
      when 'projectInvitationAccepted'
        templateUrl = '/scripts/views/_shared/notice-pop-templates/project-invitation-accepted.html'
      when 'projectInvitationRejected'
        templateUrl = '/scripts/views/_shared/notice-pop-templates/project-invitation-rejected.html'
      when 'newUserAdded'
        templateUrl = '/scripts/views/_shared/notice-pop-templates/new-user-added.html'


    mpTemplateCache.get(templateUrl).then (template) ->
      element.html($compile(template)(scope))
]
