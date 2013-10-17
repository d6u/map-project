###
MpUserNode manage user socket clients save/retrieval and various other
  operations, such as publish chat message to users belongs to specified
  project
###

q       = require('q')
_       = require('lodash')
redis   = require('redis').createClient()
pgQuery = require('./pg_query_helper')
logger  = require('tracer').colorConsole();


redis.on 'error', (err) ->
  logger.warn "Redis error " + err


# --- Modules ---
module.exports = {


  # --- Init ---
  setSocketIo: (@socketIo) ->


  # --- Socket Management ---
  # get socket by socket id (not user id)
  getSocket: (id) ->
    return _.find(@socketIo.sockets.clients(), {id: id})


  # add socket id to Redis
  #   return promise, resolve with all socket ids belongs to same user
  addSocket: (socket) ->
    allSocket = q.defer()
    userId = socket.handshake.user.id
    redis.sadd "user:#{userId}:socket_ids", socket.id, =>
      @getUserSocketIds(userId).then(
        ((ids) -> allSocket.resolve(ids)),
        (-> logger.warn('No socket ids found! Should don\'t be happending.'))
      )
    return allSocket.promise


  # remove socket id from Redis
  #   return promise, resolve with other socket ids belongs to same user
  #   resolve into empty array if no more socket online
  # also removes user:#{id}:socket_ids entry if the set is empty
  removeSocket: (socket) ->
    socketLeft = q.defer()
    userId     = socket.handshake.user.id
    redis.srem "user:#{userId}:socket_ids", socket.id
    @getUserSocketIds(userId).then(
      ((ids) -> socketLeft.resolve(ids)),
      (->
        redis.del "user:#{userId}:socket_ids"
        socketLeft.resolve([])
      )
    )
    return socketLeft.promise


  getUserSocketIds: (userId) ->
    foundIds = q.defer()
    redis.smembers "user:#{userId}:socket_ids", (err, ids) =>
      if ids.length then foundIds.resolve(ids) else foundIds.reject()
    return foundIds.promise


  # --- user data management ---
  getOnlineFriendsIds: (userId) ->
    # query friends
    return pgQuery('SELECT friend_id
             FROM friendships
             WHERE user_id = $1 AND status > 0',
            [userId])
    .then (friendships) =>
      logger.debug(friendships)
      # cache friend ids in redis
      @cacheFriendsIds(_.pluck(friendships, 'friend_id'), userId)
      # create promises array
      allFriendsChecked = []
      # check online status for each friend
      friendships.forEach (friendship) =>
        friendChecked = q.defer()
        allFriendsChecked.push(friendChecked.promise)
        @getUserSocketIds(friendship.friend_id).then(
          ((ids) -> friendChecked.resolve(friendship.friend_id)),
          (      -> friendChecked.resolve(null))
        )
      # wain for all friend checked
      #   friendIds contains null value if related friend is not online
      return q.all(allFriendsChecked).then (ids) ->
        return _.filter(ids, (id) -> _.isNumber(id))


  # --- Project Data Management ---
  getProjectUserIds: (projectId) ->
    found = q.defer()
    redis.smembers "project:#{projectId}:user_ids", (err, ids) =>
      if ids.length then found.resolve(ids) else found.reject()
    return found.promise


  # currently is not very useful because cached data is not used anywhere
  cacheFriendsIds: (friendIds, userId) ->
    if friendIds.length
      redis.sadd "user:#{userId}:friend_ids", friendIds


  # --- send data to client ---
  pushDataToSocket: (socket, eventName, data) ->
    socket.emit(eventName, data)


  # eachCallback will be called with (socket, eventName, data, userId) as
  #   arguments, for each socket connection belongs to particular user.
  #   If eachCallback returns false, data won't be sent for the socket in
  #   current loop.
  pushDataToUserId: (userId, eventName, data, eachCallback) ->
    @getUserSocketIds(userId).then (ids) =>
      for id in ids
        socket = @getSocket(id)
        if eachCallback?
          result = eachCallback(socket, eventName, data, userId)?
          if result? && result != false
            socket.emit eventName, data
        else
          socket.emit eventName, data
}
