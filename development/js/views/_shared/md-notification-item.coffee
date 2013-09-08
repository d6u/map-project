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
        mpTemplateCache.get('/scripts/views/_shared/notice-templates/add-friend-request.html')
        .then (template) ->
          element.html($compile(template)(scope))
]
