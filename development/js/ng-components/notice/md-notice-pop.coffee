app.directive 'mdNoticePop',
['$timeout', 'MpNotification', ($timeout, MpNotification) ->

  controllerAs: 'mdNoticePop'
  controller: ['$scope', class MdNoticePopCtrl

    constructor: ($scope) ->
      # --- Pop Notice ---
      @notices  = []
      @_notices = _.clone(MpNotification.notifications)

      $scope.$watch (->
        MpNotification.notifications.length
      ), =>
        newNotice = _.difference(MpNotification.notifications, @_notices)
        @_notices = _.clone(MpNotification.notifications)
        # remove each notice individually after added 3000ms
        newNotice.forEach (notice) =>
          @notices.push notice
          $timeout (=>
            @notices = _.without(@notices, notice)
          ), 3000


      # --- Unread Notice Count on Bottom Bar ---
      @unreadNotice = MpNotification.notifications.length

      # increase unread count when new notice arrives
      $scope.$watch (->
        MpNotification.notifications.length
      ), (newVal, oldVal) =>
        if newVal > oldVal
          @unreadNotice += newVal - oldVal

      # clear unread count after opened side menu
      $scope.$watch 'interface.showUserSection', (newVal) =>
        @unreadNotice = 0 if newVal == true

  ]
  link: (scope, element, attrs, MdNoticePopCtrl) ->

    element.on 'click', 'li', ->
      $timeout (->
        MdNoticePopCtrl.notices  = []
        MdNoticePopCtrl._notices = _.clone(MpNotification.notifications)
      ), 500
]
