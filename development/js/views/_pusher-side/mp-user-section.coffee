# mp-user-section
# --------------------------------------------
app.directive 'mpUserSection',
['$location', 'Restangular', 'mpTemplateCache', '$routeSegment', '$compile',
( $location,   Restangular,   mpTemplateCache,   $routeSegment,   $compile) ->

  currentTemplate = ->
    if $routeSegment.name == 'ot'
      return '/scripts/views/_pusher-side/mp-user-section-before-login.html'
    else return '/scripts/views/_pusher-side/md-user-section-inside.html'

  # return
  scope: true
  controller: ['$scope', '$element', 'mpTemplateCache', '$compile',
    ($scope, $element, mpTemplateCache, $compile) ->

      @fbLogin = ->
        $scope.MpUser.login ->
          if $scope.TheProject.places.length > 0
            return $scope.MpProjects.createProject().then (project) ->
              $places = project.all('places')
              $scope.MpProjects.TheProject = $scope.TheProject
              return '/project/'+project.id
          else return '/dashboard'

      @logout = ->
        $scope.MpUser.logout()

      @showEmailLogin = ->
        mpTemplateCache.get('/scripts/views/_pusher-side/mp-user-section-login-form.html').then (template) ->
          $element.html $compile(template)($scope)

      @showEmailRegister = ->
        mpTemplateCache.get('/scripts/views/_pusher-side/mp-user-section-before-login.html').then (template) ->
          $element.html $compile(template)($scope)

      # Friend request handler
      # ----------------------------------------
      @sendFriendRequest = (user) ->
        Restangular.all('friendships').post({friend_id: user.id, status: 0})
        .then($scope.MpChatbox.sendFriendRequest,
          # client error, most likly due to duplicate requests
          ((error) ->
            user.systemMessage = error.data.message if error.data.error == true
          ))


      @acceptFriendRequest = (notice) ->
        friendship = Restangular.one('friendships', notice.body.friendship_id)
        friendship.status = 1
        friendship.put().then(
          ((friend) ->
            $scope.MpChatbox.notifications = _.without $scope.MpChatbox.notifications, notice
            $scope.MpChatbox.friends.push friend
            $scope.MpChatbox.sendFriendAcceptNotice(friend)
          ),
          (->
            $scope.MpChatbox.notifications = _.without $scope.MpChatbox.notifications, notice
          ))


      @ignoreFriendRequest = (notice) ->
        $scope.MpChatbox.notifications = _.without $scope.MpChatbox.notifications, notice
        Restangular.one('friendships', notice.body.friendship_id).remove()
  ]
  link: (scope, element, attrs, mpUserSectionCtrl) ->

    scope.mpUserSection = mpUserSectionCtrl

    mpTemplateCache.get(currentTemplate()).then (template) ->
      element.html $compile(template)(scope)
    scope.interface.showUserSection = false


    # events
    # ----------------------------------------
    scope.$watch 'mpUserSection.searchFriendsInput', (newVal, oldVal) ->
      if newVal && newVal.length > 0
        $users = Restangular.all 'users'
        $users.getList({name: newVal}).then (users) ->
          scope.mpUserSection.searchFriendsResults = users
]
