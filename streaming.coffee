##
# Streaming Server
#   - Chat and notification streaming


# --- Intialization ---
# core modules
httpServer = require('http').createServer()
SocketIo   = require('socket.io')
RedisStore = require('socket.io/lib/stores/redis')
redis      = require('redis')

# helper modules
q          = require('q')
_          = require('lodash')

# custom modules
pgQuery    = require('./development/node/pg_query_helper')
MpNotificationService = require('./development/node/mp_notification_service')


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
socketIo.set('log level', 3)

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
      user_id = Number(user_data[0])
      pgQuery('SELECT * FROM users WHERE id = $1;', [user_id]).then (results) ->
        handshakeData.user = results[0]
        callback(null, true)
    else
      callback(null, false)


# --- Run ---
mpNotificationService = new MpNotificationService(socketIo)

# node.js server
httpServer.listen(4000)
console.log "==> Node server running on port 4000"
