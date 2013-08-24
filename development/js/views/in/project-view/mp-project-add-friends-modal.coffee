app.directive 'mpProjectAddFriendsModal', [->

  templateUrl: '/scripts/views/in/project-view/md-project-manage-friends.html'
  controller: ['$element', '$scope', ($element, $scope) ->

    @closeModal = ->
      $element.removeClass 'md-show'

    @sendInvitations = ->
      selectedFriends = _.where $scope.MpChatbox.friends, '$$selected'
      $scope.TheProject.addParticipatedUsers(selectedFriends).then ->
        for user in selectedFriends
          $scope.MpChatbox.sendProjectAddUserNotice($scope.TheProject, user)

    @getNotParticipatedUsers = ->
      return _.filter $scope.MpChatbox.friends, (friend) ->
        !_.find($scope.TheProject.participatedUsers, {id: friend.id})

    @projectRemoveUser = (user) ->
      user.$$selected = false
      $scope.TheProject.removeParticipatedUser(user).then ->
        $scope.MpChatbox.sendProjectRemoveUserNotice($scope.TheProject.project, user)


    return
  ]
  controllerAs: 'mpProjectAddFriendsModalCtrl'
  link: (scope, element, attrs, mpProjectAddFriendsModalCtrl) ->

    element.next().on 'click', mpProjectAddFriendsModalCtrl.closeModal

    scope.$on attrs.mpProjectAddFriendsModal, (event, data) ->
      for friend in scope.MpChatbox.friends
        friend.$$selected = false
      element.addClass 'md-show'
]
