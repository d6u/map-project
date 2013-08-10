##
# Streaming Server
#   - Chat and send place data


# Core Components
# ========================================
app         = require('http').createServer()
sio         = require('socket.io')
io          = sio.listen(app)
redis       = require('redis')
redisClient = redis.createClient()

# Helper
Q = require('q')
_ = require('lodash')

# Redis
redisClient.on 'ready', -> console.log '==> Redis ready'

# Server
app.listen 4000
console.log "==> Node server running on port 4000"


# Config
# ----------------------------------------
# socket.io
io.configure ->
  io.set('store', new sio.RedisStore)
  io.set('log level', 2)
  io.set 'authorization', (handshakeData, callback) ->
    cookies = handshakeData.headers.cookie.split('; ')
    user_identifier
    for pair in cookies
      if /user_identifier/.test(pair)
        user_identifier = pair.replace('user_identifier=', '')
    redisClient.get user_identifier, (err, data) ->
      if data
        user_data = data.split(':')
        handshakeData.user =
          id: Number(user_data[0])
          name: user_data[1]
          # fb_user_picture:
        callback(null, true)
      else
        callback(null, false)


# Run
# ========================================

clientsList = {}
clientsFollowersList = {}

# socket.io connection
io.sockets.on 'connection', (socket) ->

  console.log 'User connected', socket.handshake.user

  # store clients
  # ----------------------------------------
  clientSockets = clientsList[socket.handshake.user.id]
  if clientSockets
    clientSockets.push socket.id if _.findIndex(clientSockets, socket.id) == -1
  else
    clientsList[socket.handshake.user.id] = [socket.id]

  console.log clientsList
  # get online list
  # ----------------------------------------
  socket.on 'getOnlineFriendsList', (friendsIds, callback) ->
    # save friends list on client's sockets list
    clientsList[socket.handshake.user.id].friendsList = friendsIds

    onlineFriendsIds = []
    for id in friendsIds
      # check if online
      if clientsList[id] && clientsList[id].length > 0
        onlineFriendsIds.push id
        # notify friend that I'm online
        for socketId in clientsList[id]
          io.sockets.socket(socketId).emit 'userConnected', socket.handshake.user.id
    callback(onlineFriendsIds)

  # remove on disconnection
  # ----------------------------------------
  socket.on 'disconnect', ->
    console.log 'User disconnect', socket.handshake.user
    clientSockets = clientsList[socket.handshake.user.id]
    clientsList[socket.handshake.user.id] = _.without(clientsList[socket.handshake.user.id], socket.id)
    if clientsList[socket.handshake.user.id].length == 0
      # notice friends if no socket remains online
      for id in clientSockets.friendsList
        if clientsList[id] && !_.isEmpty(clientsList[id])
          console.log clientsList
          for socketId in clientsList[id]
            io.sockets.socket(socketId).emit 'userDisconnected', socket.handshake.user.id
      # remove the socket
      delete clientsList[socket.handshake.user.id]



  # userJoinLeftBehavior = (event, room) ->
  #   socket.broadcast.to(room).emit 'chatContent', {
  #     type: 'userBehavior'
  #     event: event
  #     userId: socket.handshake.user.id
  #     userName: socket.handshake.user.name
  #   }


  # socket.on 'joinRoom', (roomId, fn) ->
  #   targetRoom = 'project_room:' + roomId
  #   socket.join targetRoom
  #   userJoinLeftBehavior('joinRoom', targetRoom)
  #   console.log io.sockets.manager.roomClients[socket.id]
  #   roomClients = io.sockets.clients targetRoom
  #   roomClientIds = []
  #   for roomClient in roomClients
  #     roomClientIds.push socketList[roomClient.id].handshake.user.id
  #   fn(roomClientIds)

  # socket.on 'leaveRoom', (roomId, fn) ->
  #   # roomId will be null if no roomId
  #   if roomId
  #     userJoinLeftBehavior('leaveRoom', 'project_room:' + roomId)
  #     socket.leave 'project_room:' + roomId
  #     console.log io.sockets.manager.roomClients[socket.id]
  #   else
  #     userJoinLeftBehavior('leaveRoom', targetRoom)
  #     socket.leave targetRoom
  #     targetRoom = null
  #     console.log io.sockets.manager.roomClients[socket.id]

  # socket.on 'chatContent', (data) ->
  #   socket.broadcast.to(targetRoom).emit 'chatContent', data

  # socket.on 'disconnect', ->
  #   userJoinLeftBehavior('leaveRoom', targetRoom)
  #   console.log 'disconnect'
  #   delete socketList[socket.id]
