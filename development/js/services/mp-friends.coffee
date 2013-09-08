###
MpFriends handles user/friends query/add/show/remove
###

app.factory 'MpFriends',
['Restangular',
( Restangular) ->

  # friends
  $friends     = Restangular.all 'friends'

  # friendships
  Restangular.addElementTransformer 'friendships', false, (friendship) ->
    friendship.addRestangularMethod 'acceptFriendRequest', 'post', 'accept_friend_request'
    return friendship

  $friendships = Restangular.all 'friendships'

  # users
  Restangular.addElementTransformer 'users', false, (user) ->
    user.addFriend = ->
      @added   = true
      @pending = true
      return $friendships.post({friend_id: @id})
    return user

  $userQuery = Restangular.all 'users'


  return class MpFriends

    constructor: ->
      @friends = []
      @getFriends()


    # --- Friend interface ---
    getFriends: ->
      $friends.getList().then (friends) =>
        @friends = friends


    acceptFriendRequest: (friendship_id, notice_id) ->
      friendship = Restangular.one('friendships', friendship_id)
      extraParams = if notice_id then {notice_id: notice_id} else {}
      friendship.acceptFriendRequest(extraParams)


    # --- Search user interface ---
    findUserByName: (name) ->
      $userQuery.getList({name: name})
]
