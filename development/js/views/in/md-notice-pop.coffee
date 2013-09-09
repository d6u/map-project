app.directive 'mdNoticePop',
['$timeout', ($timeout) ->
  controllerAs: 'mdNoticePop'
  controller: ['$scope', '$timeout', ($scope, $timeout) ->

    @notices = []
    @_notices = _.clone($scope.insideViewCtrl.MpNotification.notifications)

    $scope.$watch 'insideViewCtrl.MpNotification.notifications.length', =>
      newNotice = _.difference($scope.insideViewCtrl.MpNotification.notifications, @_notices)
      @_notices = _.clone($scope.insideViewCtrl.MpNotification.notifications)
      newNotice.forEach (notice) =>
        @notices.push notice
        $timeout (=>
          @notices = _.without(@notices, notice)
        ), 3000

    # Return
    return
  ]
  link: (scope, element, attrs, mdNoticePop) ->

    element.on 'click', 'li', ->
      $timeout (->
        mdNoticePop.notices = []
        mdNoticePop._notices = _.clone(scope.insideViewCtrl.MpNotification.notifications)
      ), 500
]
