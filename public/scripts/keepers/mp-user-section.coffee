# mp-user-section
# --------------------------------------------
app.directive 'mpUserSection', ['$rootScope', '$compile', 'MpProjects',
'$location', '$timeout', 'Restangular', 'MpChatbox', 'mpTemplateCache',
'$route',
($rootScope, $compile, MpProjects, $location, $timeout, Restangular, MpChatbox,
 mpTemplateCache, $route) ->

  currentTemplate = ->
    if $route.current.$$route.controller == 'OutsideViewCtrl'
      return '/scripts/keepers/mp-user-section-before-login.html'
    else return '/scripts/keepers/mp-user-section-after-login.html'

  # return
  scope: true
  link: (scope, element, attrs) ->

    scope.fbLogin = ->
      $rootScope.User.login ->
        return if MpProjects.currentProject.places.length > 0 then '/new_project' else '/all_projects'

    scope.logout = ->
      $rootScope.User.logout()

    scope.showEmailLogin = ->
      mpTemplateCache.get('/scripts/keepers/mp-user-section-login-form.html').then (template) ->
        element.html $compile(template)(scope)

    scope.showEmailRegister = ->
      mpTemplateCache.get('/scripts/keepers/mp-user-section-before-login.html').then (template) ->
        element.html $compile(template)(scope)

    scope.showFriendsPanel = ->
      $rootScope.$broadcast 'pop_jqEasyModal', {type: 'friends_panel'}

    scope.sendFriendRequest = (id) ->
      $friendships = Restangular.all 'friendships'
      $friendships.post({friend_id: id, status: 0}).then (friendship) ->
        data =
          type: 'addFriendRequest'
          sender:
            id: $rootScope.User.getId()
            name: $rootScope.User.name()
            fb_user_picture: $rootScope.User.fb_user_picture()
          receivers_ids: [id]
          body:
            friendship_id: friendship.id
        MpChatbox.sendClientMessage(data)

    scope.acceptFriendRequest = (notice) ->
      friendship = Restangular.one('friendships', notice.body.friendship_id)
      friendship.status = 1
      friendship.put()

    scope.ignoreFriendRequest = (notice) ->
      MpChatbox.notifications = _.without MpChatbox.notifications, notice

    # init
    scope.searchFriends = {}

    # events
    # ----------------------------------------
    scope.$on '$routeChangeSuccess', (event, current) ->
      mpTemplateCache.get(currentTemplate()).then (template) ->
        element.html $compile(template)(scope)
      scope.interface.showUserSection = false
      # scope.interface.showUserSection = (current.$$route.controller == 'OutsideViewCtrl')

    scope.$watch 'searchFriends.input', (newVal, oldVal) ->
      if newVal && newVal.length > 0
        $users = Restangular.all 'users'
        $users.getList({name: newVal}).then (users) ->
          scope.searchFriends.results = users
]
