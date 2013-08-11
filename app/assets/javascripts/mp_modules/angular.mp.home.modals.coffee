app = angular.module 'angular-mp.home.modals', ['restangular']


# mp-friends-panel
app.directive 'mpFriendsPanel', ['$templateCache', '$compile', 'Restangular',
'MpChatbox',
($templateCache, $compile, Restangular, MpChatbox) ->

  link: (scope, element, attrs) ->

    scope.queryUser = ->
      if scope.friendSearchInput.length > 0
        $users = Restangular.all('users')
        $users.getList({name: scope.friendSearchInput}).then (users) ->
          _.forEach users, (user) ->
            if _.find MpChatbox.friends, {id: user.id}
              user.$$alreadyFriended = true
          scope.friendSearchResults = users

    scope.addFriend = (user) ->
      user.$$alreadyFriended = true
      Restangular.all('friendships').post({friend_id: user.id, status: 0}).then ->
        scope.$emit 'addFriendRequest', user.id

    # init
    html = $compile($templateCache.get 'mp_friends_panel_template')(scope)
    element.html html
]
