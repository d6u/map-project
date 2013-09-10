app.directive 'mdNotificationItem',
['mpTemplateCache', '$compile', (mpTemplateCache, $compile) ->

  controllerAs: 'mdNotificationItemCtrl'
  controller: ['$scope', 'MpNotification', ($scope, MpNotification) ->

    @ignoreFriendRequest = ->
      $scope.notice.ignoreFriendRequest()
      MpNotification.removeNotice($scope.notice)

    @acceptFriendRequest = ->
      $scope.insideViewCtrl.mpFriends.acceptFriendRequest($scope.notice.body.friendship_id, $scope.notice.id)
      MpNotification.removeNotice($scope.notice)

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

    mpTemplateCache.get(templateUrl).then (template) ->
      element.html($compile(template)(scope))
]
