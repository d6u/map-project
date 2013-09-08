##
# Streaming Server
#   - Chat and notification streaming


# --- Intialization ---
# core modules
httpServer = require('http').createServer()
SocketIo   = require('socket.io')
RedisStore = require('socket.io/lib/stores/redis')
redis      = require('redis')
pg         = require('pg')

# helper modules
q          = require('q')
_          = require('lodash')


# --- Configuration ----
# redis
redisClient = redis.createClient()
redisClient.on 'ready', ->
  console.log '==> Redis ready'

# socket.io
socketIo          = SocketIo.listen(httpServer)
socketRedisPub    = redis.createClient()
socketRedisSub    = redis.createClient()
socketRedisClient = redis.createClient()

socketIo.set 'store', new RedisStore({
  redisPub:    socketRedisPub
  redisSub:    socketRedisSub
  redisClient: socketRedisClient
})
socketIo.set('log level', 2)
socketIo.set 'authorization', (handshakeData, callback) ->
  ###
  {
     headers: req.headers       // <Object> the headers of the request
   , time: (new Date) +''       // <String> date time of the connection
   , address: socket.address()  // <Object> remoteAddress and remotePort object
   , xdomain: !!headers.origin  // <Boolean> was it a cross domain request?
   , secure: socket.secure      // <Boolean> https connection
   , issued: +date              // <Number> EPOCH of when the handshake was created
   , url: request.url           // <String> the entrance path of the request
   , query: data.query          // <Object> the result of url.parse().query or a empty object
  }
  ###
  cookies = handshakeData.headers.cookie.split('; ')
  user_identifier
  for pair in cookies
    if /user_identifier/.test(pair)
      user_identifier = pair.replace('user_identifier=', '')
  redisClient.get user_identifier, (err, data) ->
    if data
      # TODO: attach user data with more detail
      #   when generate sender data, completely rely on server, prevent id
      #   theft, update when user attrs changes
      user_data = data.split(':')
      handshakeData.user =
        id: Number(user_data[0])
        name: user_data[1]
      callback(null, true)
    else
      callback(null, false)


# --- Run ---
# notification service
MpNotificationService = require('./development/node/mp_notification_service')
mpNotificationService = new MpNotificationService(redis, socketIo, pg)



#   # store clients
#   # ----------------------------------------
#   clientSockets = clientsList[socket.handshake.user.id]
#   if clientSockets
#     clientSockets.push socket.id if _.findIndex(clientSockets, socket.id) == -1
#   else
#     clientsList[socket.handshake.user.id] = [socket.id]

#   # get online list
#   # ----------------------------------------
#   socket.on 'getOnlineFriendsList', (friendsIds, callback) ->
#     # save friends list on client's sockets list
#     console.log 'getOnlineFriendsList', friendsIds
#     clientsList[socket.handshake.user.id].friendsList = friendsIds

#     onlineFriendsIds = []
#     for id in friendsIds
#       # check if online
#       if clientsList[id] && clientsList[id].length > 0
#         onlineFriendsIds.push id
#         # notify friend that I'm online
#         for socketId in clientsList[id]
#           io.sockets.socket(socketId).emit 'userConnected', socket.handshake.user.id
#     callback(onlineFriendsIds)
#     console.log clientsList

#   # remove on disconnection
#   # ----------------------------------------
#   socket.on 'disconnect', ->
#     console.log 'User disconnect', socket.handshake.user
#     friendsList = clientsList[socket.handshake.user.id].friendsList
#     clientsList[socket.handshake.user.id] = _.without(clientsList[socket.handshake.user.id], socket.id)
#     clientsList[socket.handshake.user.id].friendsList = friendsList
#     if clientsList[socket.handshake.user.id] && clientsList[socket.handshake.user.id].length == 0
#       # notice friends if no socket remains online
#       if friendsList
#         for id in friendsList
#           if clientsList[id] && clientsList[id].length > 0
#             for socketId in clientsList[id]
#               io.sockets.socket(socketId).emit 'userDisconnected', socket.handshake.user.id
#       # remove the socket
#       delete clientsList[socket.handshake.user.id]
#     console.log clientsList

#   # client message
#   # ----------------------------------------
#   socket.on 'clientData', (data) ->
#     console.log 'receive clientMessage', data
#     _.forEach data.receivers_ids, (id) ->
#       if clientsList[id] && clientsList[id].length > 0
#         _.forEach clientsList[id], (socketId) ->
#           io.sockets.socket(socketId).emit 'serverData', data



# Run
# ========================================
httpServer.listen(4000)
console.log "==> Node server running on port 4000"
