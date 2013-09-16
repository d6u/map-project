###
MpFriends handles user/friends query/add/show/remove
###

app.service 'MpFriends',
['Restangular', 'socket', '$q', class MpFriends

  constructor: (@Restangular, @socket, @$q) ->
    @friends          = []
    @onlineFriendsIds = []

    # --- Resouces ---
    @$$friends     = Restangular.all 'friends'
    @$$friendships = Restangular.all 'friendships'
    @$$userQuery   = Restangular.all 'users'

    # --- Socket.io ---
    # push sync
    socket.on 'onlineFriendsList', (ids) =>
      @onlineFriendsIds = ids

    socket.on 'friendGoOnline', (id) =>
      @onlineFriendsIds = _.union(@onlineFriendsIds, [id])

    socket.on 'friendGoOffline', (id) =>
      @onlineFriendsIds = _.without(@onlineFriendsIds, id)

    socket.on 'serverData', (data) =>
      if data.type == 'addFriendRequestAccepted'
        @addUserToFriendsList(data.sender)


  # --- Login/out process management ---
  initialize: (scope) ->
    refreshFriendsOnlineStatus = =>
      for friend in @friends
        friend.$online = if _.indexOf(@onlineFriendsIds, friend.id) >= 0 then true else false
    # watch friends changes
    scope.$watch (=>
      _.pluck(@friends, 'id').sort()
    ), refreshFriendsOnlineStatus, true
    # watch onlineFriendsIds changes
    scope.$watch (=>
      @onlineFriendsIds.sort()
    ), refreshFriendsOnlineStatus, true

    @getFriends()

    scope.$on '$destroy', =>
      @destroy()

  destroy: ->
    @friends          = []
    @onlineFriendsIds = []


  # --- Friend interface ---
  getFriends: ->
    @$$friends.getList().then (friends) =>
      @friends = friends

  syncFriendsOnlineStatus: (onlineFriendsList) ->
    @socket.emit 'requestOnlineFriendsList', undefined, (ids) =>
      @onlineFriendsIds = ids

  addUserToFriendsList: (user) ->
    newFriend = @Restangular.one('friends', user.id)
    angular.extend(newFriend, user)
    @friends.push newFriend


  # --- Friendship interface ---
  addUserAsFriend: (user) ->
    user.added   = true
    user.pending = true
    @$$friendships.post({friend_id: user.id})


  # --- Search user interface ---
  findUserByName: (name) ->
    @$$userQuery.getList({name: name})
]
