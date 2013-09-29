app.directive 'mdSideMenu',
['$routeSegment', 'MpNotification', ($routeSegment, MpNotification) ->

  templateUrl: ->
    if $routeSegment.startsWith('ot') then '/scripts/ng-components/side-menu/md-side-menu-outside.html' else '/scripts/ng-components/side-menu/md-side-menu-inside.html'
  replace: true
  controllerAs: 'MdSideMenuCtrl'
  controller: ['$scope', 'MpUser', '$location', class MdSideMenuCtrl

    constructor: ($scope, MpUser, $location) ->
      # --- Outside ---
      @outsideActiveSection = 'register'
      @registerFormData = {}
      @registerUser = (userData) ->
        MpUser.emailRegister userData, ->
          $location.path '/dashboard'

      @loginUser = ->
        if @loginForm.$valid
          MpUser.emailLogin @loginFormData, ->
            $location.path '/dashboard'


      # --- Remove No Action Required Notice when Side Menu is Open ---
      noActionRequiredNotice = [
        'addFriendRequestAccepted'
        'projectInvitationAccepted'
        'projectInvitationRejected'
        'newUserAdded'
        'youAreRemovedFromProject'
      ]

      # store notice id that already removed from server but still have a copy
      #   in local
      alreadyRemovedNoticeIds = []

      $scope.$watch 'interface.showUserSection', (newVal) ->
        return if newVal != true
        for notice in MpNotification.notifications
          if noActionRequiredNotice.indexOf(notice.type) > -1 &&
          alreadyRemovedNoticeIds.indexOf(notice.id) == -1
            notice.remove()
            alreadyRemovedNoticeIds.push(notice.id)

  ]
  link: (scope, element, attrs, MdSideMenuCtrl) ->

    element.on 'click', '.md-side-menu-actions-item-anchor', (event) ->
      scope.interface.showUserSection = false
      return # prevent return false
]
