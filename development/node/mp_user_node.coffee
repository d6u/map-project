###
MpUserNode manage user socket clients save/retrieval and various other
  operations, such as publish chat message to users belongs to specified
  project
###

q       = require('q')
_       = require('lodash')
redis   = require('redis')
rClient = redis.createClient()
pgQuery = require('./pg_query_helper')
logger  = require('tracer').colorConsole();


rClient.on 'error', (err) ->
  logger.warn "Redis error " + err


# --- Modules ---
module.exports = {

  # --- Helpers ---
  setSockets: (@sockets) ->
  findSocketById: (id) ->
    return _.find(@sockets.clients(), {id: id})


  # --- socket management ---
  addSocketToUserNode: (socket) ->
    rClient.sadd "user:#{socket.handshake.user.id}:socket_ids", socket.id

  removeSocketFromUserNode: (socket) ->
    userId = socket.handshake.user.id
    rClient.srem "user:#{userId}:socket_ids", socket.id
    @getUserSocketIds(userId).then undefined, ->
      rClient.del "user:#{userId}:socket_ids"

  getUserSocketIds: (userId) ->
    findIds = q.defer()
    rClient.smembers "user:#{userId}:socket_ids", (err, socketIds) =>
      if socketIds.length then findIds.resolve(socketIds) else findIds.reject()
    return findIds.promise


  # --- user data management ---
  getOnlineFriendIds: (socket) ->
    # query friends
    pgQuery('SELECT friend_id FROM friendships WHERE user_id = $1 AND status > 0',
    [socket.handshake.user.id]).then (friendships) =>
      # create promises array
      allFriendsChecked = []
      # check online status for each friend
      friendships.forEach (friendship) =>
        friendChecked = q.defer()
        allFriendsChecked.push friendChecked.promise
        @getUserSocketIds(friendship.friend_id).then ((socketIds) ->
          friendChecked.resolve(friendship.friend_id)
        ), ->
          friendChecked.resolve(null)
      # wain for all friend checked
      #   friendIds contains null value if related friend is not online
      q.all(allFriendsChecked).then (friendIds) ->
        _.filter friendIds, (id) -> _.isNumber(id)


  # --- send data to client ---
  pushOnlineFriendIds: (socket) ->
    @getOnlineFriendIds(socket).then (onlineFriendIds) =>
      socket.emit 'onlineFriendsList', onlineFriendIds

  pushMessageToUserId: (userId, eventName, data, eachCallback) ->
    @getUserSocketIds(userId).then (socketIds) =>
      for socketId in socketIds
        socket = @findSocketById(socketId)
        socket.emit eventName, data
        eachCallback(socket, eventName, data, userId) if eachCallback
}
