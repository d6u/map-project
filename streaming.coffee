##
# Streaming Server
#   - Chat and send place data


# Core Components
# ========================================
app         = require('http').createServer()
io          = require('socket.io').listen(app)
redis       = require('redis')
redisClient = redis.createClient()

# Helper
Q = require('q')

# Redis
redisClient.on 'ready', -> console.log '==> Redis ready'

# Server
app.listen 4000
console.log "==> Node server running on port 4000"


# Config
# ----------------------------------------
# socket.io
io.configure ->
  io.set 'authorization', (handshakeData, callback) ->
    cookies = handshakeData.headers.cookie.split('; ')
    user_identifier
    for pair in cookies
      if /user_identifier/.test(pair)
        user_identifier = pair.replace('user_identifier=', '')
    redisClient.get user_identifier, (err, data) ->
      user_data = data.split(':')
      handshakeData.user = {profile_id: user_data[0], name: user_data[1]}
    callback(null, true)


# Run
# ========================================
# socket.io connection
io.sockets.on 'connection', (socket) ->

  targetRoom = null

  socket.on 'joinRoom', (roomId, fn) ->
    targetRoom = 'project_room:' + roomId
    socket.join targetRoom
    console.log io.sockets.manager.roomClients[socket.id]
    fn()

  socket.on 'leaveRoom', (roomId, fn) ->
    # roomId will be null if no roomId
    if roomId
      socket.leave 'project_room:' + roomId
      console.log io.sockets.manager.roomClients[socket.id]
    else
      socket.leave targetRoom
      console.log io.sockets.manager.roomClients[socket.id]

  socket.on 'chatContent', (data) ->
    socket.broadcast.to(targetRoom).emit 'chatContent', data
