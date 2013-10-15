app.directive 'mdSideMenuInside',
['MpNotices','MpUI',
( MpNotices,  MpUI) ->

  templateUrl:  '/scripts/ng-components/side-menu/md-side-menu-inside.html'
  replace:      true
  controllerAs: 'MdSideMenuInsideCtrl'
  controller: ['$scope', 'MpUser', '$location', class MdSideMenuInsideCtrl

    constructor: ($scope, MpUser, $location) ->

      # --- Constants ---
      NO_ACTION_REQUIRED_NOTICE = [5, 15, 16, 25, 26, 35, 36, 45, 46, 55]


      # --- Listeners ---
      $scope.$watch (->
        return MpNotices.models
      ), =>
        @notices = MpNotices.models


      # removed from server, but still have a local copy
      destroyedNoticeIds = []

      $scope.$watch (->
        return MpUI.showSideMenu
      ), (newVal) =>
        return if newVal != true
        for notice in @notices
          if _.indexOf(NO_ACTION_REQUIRED_NOTICE, notice.get('notice_type')) > -1 &&
          _.indexOf(destroyedNoticeIds, notice.id) == -1
            MpNotices.remove(notice)
            destroyedNoticeIds.push(notice.id)
  ]
  link: (scope, element, attrs, MdSideMenuInsideCtrl) ->

    element.on 'click', '.md-side-menu-actions-item-anchor', (event) ->
      MpUI.showSideMenu = false
      return # prevent return false
]
