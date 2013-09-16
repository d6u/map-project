app.directive 'mdNoticePopItem',
['mpTemplateCache', '$compile', (mpTemplateCache, $compile) ->

  (scope, element, attrs) ->

    switch scope.notice.type
      when 'addFriendRequest'
        templateUrl = '/scripts/components/notice/notice-pop-templates/add-friend-request.html'
      when 'addFriendRequestAccepted'
        templateUrl = '/scripts/components/notice/notice-pop-templates/add-friend-request-accepted.html'
      when 'projectInvitation'
        templateUrl = '/scripts/components/notice/notice-pop-templates/project-invitation.html'
      when 'projectInvitationAccepted'
        templateUrl = '/scripts/components/notice/notice-pop-templates/project-invitation-accepted.html'
      when 'projectInvitationRejected'
        templateUrl = '/scripts/components/notice/notice-pop-templates/project-invitation-rejected.html'
      when 'newUserAdded'
        templateUrl = '/scripts/components/notice/notice-pop-templates/new-user-added.html'
      when 'youAreRemovedFromProject'
        templateUrl = '/scripts/components/notice/notice-pop-templates/you-are-removed-from-project.html'
      when 'projectUserListUpated'
        templateUrl = '/scripts/components/notice/notice-pop-templates/project-user-list-update.html'

    mpTemplateCache.get(templateUrl).then (template) ->
      element.html($compile(template)(scope))
]
