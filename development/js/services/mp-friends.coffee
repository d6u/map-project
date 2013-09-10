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
    socket.on 'connect', =>
      @syncFriendsOnlineStatus()


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

  syncFriendsOnlineStatus: (onlineFriendsList) ->
    @socket.emit 'requestOnlineFriendsList', undefined, (ids) =>
      @onlineFriendsIds = ids

  addUserToFriendsList: (user) ->
    newFriend = @Restangular.one('friends', user.id)
    angular.extend(newFriend, user)
    @friends.push newFriend
    @syncFriendsOnlineStatus()


  # --- Friendship interface ---
  addUserAsFriend: (user) ->
    user.added   = true
    user.pending = true
    @$$friendships.post({friend_id: user.id})


  # --- Search user interface ---
  findUserByName: (name) ->
    @$$userQuery.getList({name: name})
]
