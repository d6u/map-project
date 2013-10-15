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

    switch scope.notice.type
      when 'addFriendRequest'
        templateUrl = '/scripts/ng-components/notice/notice-templates/add-friend-request.html'
      when 'addFriendRequestAccepted'
        templateUrl = '/scripts/ng-components/notice/notice-templates/add-friend-request-accepted.html'
      when 'projectInvitation'
        templateUrl = '/scripts/ng-components/notice/notice-templates/project-invitation.html'
      when 'projectInvitationAccepted'
        templateUrl = '/scripts/ng-components/notice/notice-templates/project-invitation-accepted.html'
      when 'projectInvitationRejected'
        templateUrl = '/scripts/ng-components/notice/notice-templates/project-invitation-rejected.html'
      when 'newUserAdded'
        templateUrl = '/scripts/ng-components/notice/notice-templates/new-user-added.html'
      when 'youAreRemovedFromProject'
        templateUrl = '/scripts/ng-components/notice/notice-templates/you-are-removed-from-project.html'
      when 'projectUserListUpated'
        templateUrl = '/scripts/ng-components/notice/notice-templates/project-user-list-updated.html'

    mpTemplateCache.get(templateUrl).then (template) ->
      element.html($compile(template)(scope))
]
