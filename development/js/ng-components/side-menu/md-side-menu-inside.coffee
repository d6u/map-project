app.directive 'mdSideMenuInside',
['MpNotification','MpUI',
( MpNotification,  MpUI) ->

  templateUrl:  '/scripts/ng-components/side-menu/md-side-menu-inside.html'
  replace:      true
  controllerAs: 'MdSideMenuInsideCtrl'
  controller: ['$scope', 'MpUser', '$location', class MdSideMenuInsideCtrl

    constructor: ($scope, MpUser, $location) ->

      # --- Remove No Action Required Notice when Side Menu is Open ---
      noActionRequiredNotice = [
        'addFriendRequestAccepted'
        'projectInvitationAccepted'
        'projectInvitationRejected'
        'newUserAdded'
        'youAreRemovedFromProject'
      ]

      # store notice id that already removed from server but has a local copy
      alreadyRemovedNoticeIds = []

      $scope.$watch 'interface.showUserSection', (newVal) ->
        return if newVal != true
        for notice in MpNotification.notifications
          if noActionRequiredNotice.indexOf(notice.type) > -1 &&
          alreadyRemovedNoticeIds.indexOf(notice.id) == -1
            notice.remove()
            alreadyRemovedNoticeIds.push(notice.id)

  ]
  link: (scope, element, attrs, MdSideMenuInsideCtrl) ->

    element.on 'click', '.md-side-menu-actions-item-anchor', (event) ->
      MpUI.showSideMenu = false
      return # prevent return false
]
