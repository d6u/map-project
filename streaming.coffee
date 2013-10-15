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
logger     = require('tracer').colorConsole()

# custom modules
pgQuery    = require('./development/node/pg_query_helper')
MpUserNode = require('./development/node/mp_user_node')


# --- Configuration ----
# redis
redisClient = redis.createClient()

# socket.io
socketIo    = SocketIo.listen(httpServer)

socketIo.set 'store', new RedisStore({
  redisPub:    redis.createClient()
  redisSub:    redis.createClient()
  redisClient: redis.createClient()
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
        callback('Could not find related session in Redis', false)


# --- Run ---
redisClient.on 'ready', ->
  # reset redis db
  redisClient.keys 'user:*:socket_ids', (err, keys) ->
    redisClient.del keys, (err, data) ->
      logger.info '==> Redis ready'
      # node.js server
      httpServer.listen(4000)
      logger.info "==> Node server running on port 4000"


# --- Main ---
MpUserNode.setSocketIo(socketIo)


# --- Redis pub/sub ---
subscriber = redis.createClient()
subscriber.subscribe 'notice_channel'
subscriber.on 'subscribe', (channel, count) ->
  logger.info "==> MpNotificationService subscribed #{channel}, subscribed #{count} channels in total"

# sub message
subscriber.on 'message', (channel, message) ->
  logger.debug '--> Redis receive message: ', message
  if channel == 'notice_channel'
    data = JSON.parse(message)
    MpUserNode.pushDataToUserId(data.receiver_id, 'pushData', data)


# -- Sub Chat Message --
chatSubscriber = redis.createClient()
chatSubscriber.subscribe 'chat_channel'
chatSubscriber.on 'message', (channel, message) ->
  logger.debug "--> Redis receive message from #{channel}: ", message
  if channel == 'chat_channel'
    data = JSON.parse(message)
    MpUserNode.getProjectUserIds(data.project_id).then (ids) ->
      for id in ids
        MpUserNode.pushDataToUserId(id, 'chatData', data)


# --- Socket.io connection ---
socketIo.sockets.on 'connection', (socket) ->

  userId = socket.handshake.user.id
  firstConnection = q.defer() # resolve if true, reject if false

  # connection
  logger.info "--> user:#{userId}, socket:#{socket.id} connected"
  MpUserNode.addSocket(socket).then (ids) ->
    if ids.length == 1
      logger.info "--> This is user:#{userId}'s first connection"
      firstConnection.resolve()
    else
      firstConnection.reject()

  MpUserNode.getOnlineFriendsIds(userId).then (ids) ->
    MpUserNode.pushDataToSocket(socket, 'friendsOnlineIds', ids)
    firstConnection.promise.then(
      (->
        for id in ids
          MpUserNode.pushDataToUserId(id, 'friendGoOnline', userId)
      )
    )


  # request online friends list
  socket.on 'requestOnlineFriendsList', (data, done) ->
    MpUserNode.getOnlineFriendsIds(userId).then (ids) ->
      done(ids)


  # disconnect
  socket.on 'disconnect', ->
    logger.info "--> user:#{userId}, socket:#{socket.id} disconnected"
    MpUserNode.removeSocket(socket).then (idsLeft) ->
      if !idsLeft.length
        logger.info "--> All of user:#{userId}'s socket disconnected"
        MpUserNode.getOnlineFriendsIds(userId).then (ids) ->
          for id in ids
            MpUserNode.pushDataToUserId(id, 'friendGoOffline', userId)
