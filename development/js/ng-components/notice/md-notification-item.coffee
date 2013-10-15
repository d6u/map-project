app.directive 'mdNotificationItem',
['mpTemplateCache', '$compile', (mpTemplateCache, $compile) ->

  controllerAs: 'mdNotificationItemCtrl'
  controller: ['$scope', 'MpNotices', 'MpFriends', ($scope, MpNotices, MpFriends) ->

    @ignoreFriendRequest = ->
      MpNotices.ignoreFriendRequest($scope.notice)

    @acceptFriendRequest = ->
      MpNotices.acceptFriendRequest($scope.notice)

    @rejectProjectInvitation = ->
      MpNotices.rejectProjectInvitation($scope.notice)

    @acceptProjectInvitation = ->
      MpNotices.acceptProjectInvitation($scope.notice)


    return
  ]

  link: (scope, element, attrs, mdNotificationItemCtrl) ->

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
        templateName = 'project-user-list-updated'


    templateUrl = "/scripts/ng-components/notice/notice-templates/#{templateName}.html"


    mpTemplateCache.get(templateUrl).then (template) ->
      element.html( $compile(template)(scope)[0] )
]
