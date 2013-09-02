app.directive 'mpProjectAddFriendsModal', [->

  templateUrl: '/scripts/views/in/project/md-project-manage-friends.html'
  controllerAs: 'mpProjectAddFriendsModalCtrl'
  controller: ['$element', '$scope', ($element, $scope) ->

    @closeModal = ->
      $element.removeClass 'md-show'

    @sendInvitations = ->
      selectedFriends = _.where $scope.insideViewCtrl.MpChatbox.friends, '$$selected'
      $scope.mapCtrl.theProject.addParticipatedUsers(selectedFriends).then ->
        for user in selectedFriends
          $scope.insideViewCtrl.MpChatbox.sendProjectAddUserNotice($scope.mapCtrl.theProject, user)

    @getNotParticipatedUsers = ->
      return _.filter $scope.insideViewCtrl.MpChatbox.friends, (friend) ->
        !_.find($scope.mapCtrl.theProject.participatedUsers, {id: friend.id})

    @projectRemoveUser = (user) ->
      user.$$selected = false
      $scope.mapCtrl.theProject.removeParticipatedUser(user).then ->
        $scope.insideViewCtrl.MpChatbox.sendProjectRemoveUserNotice($scope.mapCtrl.theProject.project, user)

    return
  ]
  link: (scope, element, attrs, mpProjectAddFriendsModalCtrl) ->

    element.next().on 'click', mpProjectAddFriendsModalCtrl.closeModal

    scope.$on attrs.mpProjectAddFriendsModal, (event, data) ->
      for friend in scope.insideViewCtrl.MpChatbox.friends
        friend.$$selected = false
      element.addClass 'md-show'
]
