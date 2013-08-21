app.directive 'mpProjectAddFriendsModal', [->

  templateUrl: '/scripts/views/project-view/md-project-manage-friends.html'
  controller: ['$element', '$scope', ($element, $scope) ->

    @closeModal = ->
      $element.removeClass 'md-show'

    @sendInvitations = ->
      $users = $scope.TheProject.project.all('users')
      selectedFriends = _.where $scope.MpChatbox.friends, '$$selected'
      ids = _.pluck selectedFriends, 'id'
      $users.post({user_ids: ids.join(',')}).then (users) ->
        # server will return an array of all participated users

    @getNotParticipatedUsers = ->
      return _.filter $scope.MpChatbox.friends, (friend) ->
        if !_.find($scope.TheProject.participatedUsers, {id: friend.id})
          return true
        else
          return false

    @projectRemoveUser = (user) ->
      $scope.TheProject.removeParticipatedUser(user)


    return
  ]
  controllerAs: 'mpProjectAddFriendsModalCtrl'
  link: (scope, element, attrs) ->

    element.next().on('click', ->
      element.removeClass 'md-show'
    )

    scope.$on attrs.mpProjectAddFriendsModal, (event, data) ->
      element.addClass 'md-show'
]
