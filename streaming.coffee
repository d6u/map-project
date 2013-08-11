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

  # get online list
  # ----------------------------------------
  socket.on 'getOnlineFriendsList', (friendsIds, callback) ->
    # save friends list on client's sockets list
    console.log 'getOnlineFriendsList', friendsIds
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
    console.log clientsList

  # remove on disconnection
  # ----------------------------------------
  socket.on 'disconnect', ->
    console.log 'User disconnect', socket.handshake.user
    friendsList = clientsList[socket.handshake.user.id].friendsList
    clientsList[socket.handshake.user.id] = _.without(clientsList[socket.handshake.user.id], socket.id)
    clientsList[socket.handshake.user.id].friendsList = friendsList
    if clientsList[socket.handshake.user.id] && clientsList[socket.handshake.user.id].length == 0
      # notice friends if no socket remains online
      if friendsList
        for id in friendsList
          if clientsList[id] && clientsList[id].length > 0
            for socketId in clientsList[id]
              io.sockets.socket(socketId).emit 'userDisconnected', socket.handshake.user.id
      # remove the socket
      delete clientsList[socket.handshake.user.id]
    console.log clientsList

  # client message
  # ----------------------------------------
  socket.on 'clientMessage', (data) ->
    console.log 'receive clientMessage', data
    _.forEach data.receivers_ids, (id) ->
      if clientsList[id] && clientsList[id].length > 0
        _.forEach clientsList[id], (socketId) ->
          io.sockets.socket(socketId).emit 'serverMessage', data
