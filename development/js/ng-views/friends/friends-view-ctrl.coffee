app.controller 'FriendsViewCtrl',
['MpFriends', '$scope', class FriendsViewCtrl

  constructor: (MpFriends, $scope) ->

    $scope.$watch (->
      return MpFriends.models
    ), =>
      @friends = MpFriends.models
]
