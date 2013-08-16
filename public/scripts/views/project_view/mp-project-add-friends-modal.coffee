app.directive 'mpProjectAddFriendsModal', [->
  (scope, element, attrs) ->

    element.next().on('click', ->
      element.removeClass 'md-show'
    )

    scope.closeModal = ->
      element.removeClass 'md-show'

    scope.sendInvitations = ->
      $users = scope.MpProjects.currentProject.all('users')
      selectedFriends = _.where scope.MpChatbox.friends, '$$selected'
      ids = _.pluck selectedFriends, 'id'
      $users.post({user_ids: ids.join(',')}).then (users) ->
        # server will return an array of all participated users

    scope.$on attrs.mpProjectAddFriendsModal, (event, data) ->
      element.addClass 'md-show'
]
