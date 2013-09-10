###
MpFriends handles user/friends query/add/show/remove
###

app.service 'MpFriends',
['Restangular', 'socket', class MpFriends

  constructor: (Restangular, socket) ->
    @friends          = []
    @onlineFriendsIds = []

    # --- Resouces ---
    @$$friends     = Restangular.all 'friends'
    @$$friendships = Restangular.all 'friendships'
    @$$userQuery   = Restangular.all 'users'

    # friendships
    Restangular.addElementTransformer 'friendships', false, (friendship) ->
      friendship.addRestangularMethod 'acceptFriendRequest', 'post', 'accept_friend_request'
      return friendship

    # users
    Restangular.addElementTransformer 'users', false, (user) ->
      user.addFriend = ->
        @added   = true
        @pending = true
        return $friendships.post({friend_id: @id})
      return user

    # --- Socket.io ---
    socket.on 'connect', =>
      socket.emit 'requestOnlineFriendsList', undefined, (ids) =>
        @onlineFriendsIds = ids


  # --- Login/out process management ---
  watcherDeregistrators: []

  initialize: (scope) ->
    refreshFriendsOnlineStatus = =>
      for friend in @friends
        friend.$online = if _.find(@onlineFriendsIds, friend.id) then true else false
    # watch friends changes
    @watcherDeregistrators.push scope.$watch (=>
      _.pluck(@friends, 'id').sort()
    ), refreshFriendsOnlineStatus, true
    # watch onlineFriendsIds changes
    @watcherDeregistrators.push scope.$watch (=>
      @onlineFriendsIds.sort()
    ), refreshFriendsOnlineStatus, true

    @getFriends()

  destroy: ->
    for deregistrator in @watcherDeregistrators
      deregistrator()
    @friends          = []
    @onlineFriendsIds = []


  # --- Friend interface ---
  getFriends: ->
    @$$friends.getList().then (friends) =>
      @friends = friends


  acceptFriendRequest: (friendship_id, notice_id) ->
    friendship = Restangular.one('friendships', friendship_id)
    extraParams = if notice_id then {notice_id: notice_id} else {}
    friendship.acceptFriendRequest(extraParams)


  refreshFriendsOnlineStatus: (onlineFriendsList) ->
    for friend in @friends
      if _.find(onlineFriendsList, friend.id)
        friend.$online = true


  # --- Search user interface ---
  findUserByName: (name) ->
    $userQuery.getList({name: name})
]
