app.directive 'mdNoticePopItem',
['mpTemplateCache', '$compile', (mpTemplateCache, $compile) ->

  (scope, element, attrs) ->

    switch scope.notice.get('notice_type')
      when 0
        templateName = 'add-friend-request'
      when 'addFriendRequestAccepted'
        templateName = 'add-friend-request-accepted'
      when 'projectInvitation'
        templateName = 'project-invitation'
      when 'projectInvitationAccepted'
        templateName = 'project-invitation-accepted'
      when 'projectInvitationRejected'
        templateName = 'project-invitation-rejected'
      when 'newUserAdded'
        templateName = 'new-user-added'
      when 'youAreRemovedFromProject'
        templateName = 'you-are-removed-from-project'
      when 'projectUserListUpated'
        templateName = 'project-user-list-update'


    templateUrl = "/scripts/ng-components/notice/notice-pop-templates/#{templateName}.html"


    mpTemplateCache.get(templateUrl).then (template) ->
      element.html( $compile(template)(scope)[0] )
]
