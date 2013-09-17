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
cookie     = require('cookie')

# custom modules
pgQuery    = require('./development/node/pg_query_helper')
MpNotificationService = require('./development/node/mp_notification_service')


# --- Configuration ----
# redis
redisClient = redis.createClient()

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
  cookies = cookie.parse(handshakeData.headers.cookie)
  if !cookies._session_id
    callback('_session_id is not defined in cookies', false)
    return
  else
    redisClient.get cookies._session_id, (err, data) ->
      if data
        session = JSON.parse(data)
        pgQuery('SELECT * FROM users WHERE id = $1;', [session.user_id]).then (results) ->
          handshakeData.user = results[0]
          callback(undefined, true)
      else
        callback('Could not find related session in Reids', false)


# --- Run ---
mpNotificationService = new MpNotificationService(socketIo)

redisClient.on 'ready', ->
  # reset redis db
  redisClient.keys 'user:*:socket_ids', (err, keys) ->
    redisClient.del keys, (err, data) ->
      console.log '==> Redis ready'
      # node.js server
      httpServer.listen(4000)
      console.log "==> Node server running on port 4000"
