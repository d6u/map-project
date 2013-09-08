###
MpFriends handles user/friends query/add/show/remove
###

app.factory 'MpFriends',
['Restangular',
( Restangular) ->

  $friends     = Restangular.all 'friends'
  $friendships = Restangular.all 'friendships'

  Restangular.addElementTransformer 'users', false, (user) ->
    user.addFriend = ->
      @added   = true
      @pending = true
      return $friendships.post({friend_id: @id})
    return user

  $userQuery = Restangular.all 'users'


  return class MpFriends

    constructor: ->
      @getFriends()

    # --- Friend interface ---
    getFriends: ->
      $friends.getList().then (friends) =>
        @friends = friends

    # --- Search user interface ---
    findUserByName: (name) ->
      $userQuery.getList({name: name})
]