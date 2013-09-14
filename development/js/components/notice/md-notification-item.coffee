app.directive 'mdNotificationItem',
['mpTemplateCache', '$compile', (mpTemplateCache, $compile) ->

  controllerAs: 'mdNotificationItemCtrl'
  controller: ['$scope', 'MpNotification', 'MpFriends', ($scope, MpNotification, MpFriends) ->

    @ignoreFriendRequest = ->
      MpNotification.ignoreFriendRequest($scope.notice)

    @acceptFriendRequest = ->
      MpNotification.acceptFriendRequest($scope.notice)

    @rejectProjectInvitation = ->
      MpNotification.rejectProjectInvitation($scope.notice)

    @acceptProjectInvitation = ->
      MpNotification.acceptProjectInvitation($scope.notice)


    return
  ]

  link: (scope, element, attrs, mdNotificationItemCtrl) ->

    switch scope.notice.type
      when 'addFriendRequest'
        templateUrl = '/scripts/views/_shared/notice-templates/add-friend-request.html'
      when 'addFriendRequestAccepted'
        templateUrl = '/scripts/views/_shared/notice-templates/add-friend-request-accepted.html'
      when 'projectInvitation'
        templateUrl = '/scripts/views/_shared/notice-templates/project-invitation.html'
      when 'projectInvitationAccepted'
        templateUrl = '/scripts/views/_shared/notice-templates/project-invitation-accepted.html'
      when 'projectInvitationRejected'
        templateUrl = '/scripts/views/_shared/notice-templates/project-invitation-rejected.html'
      when 'newUserAdded'
        templateUrl = '/scripts/views/_shared/notice-templates/new-user-added.html'


    mpTemplateCache.get(templateUrl).then (template) ->
      element.html($compile(template)(scope))
]
