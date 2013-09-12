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


rClient.on "error", (err) ->
  console.log "Error " + err


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
    rClient.smembers "user:#{userId}:socket_ids", (err, ids) ->
      if !ids.length
        rClient.del "user:#{userId}:socket_ids"


  # --- user data management ---
  getOnlineFriendIds: (socket) ->
    # query friends
    pgQuery('SELECT friend_id FROM friendships WHERE user_id = $1 AND status > 0',
    [socket.handshake.user.id]).then (friendships) =>
      # create promises array
      allFriendsChecked = []
      # check online status for each friend
      friendships.forEach (friendship) ->
        friendChecked = q.defer()
        allFriendsChecked.push friendChecked.promise
        rClient.smembers "user:#{friendship.friend_id}:socket_ids", (err, socketIds) ->
          friendChecked.resolve(if socketIds.length then friendship.friend_id else null)
      # wain for all friend checked
      #   friendIds contains null value if related friend is not online
      q.all(allFriendsChecked).then (friendIds) ->
        _.filter friendIds, (id) -> _.isNumber(id)


  # --- send data to client ---
  pushOnlineFriendIds: (socket) ->
    @getOnlineFriendIds(socket).then (onlineFriendIds) =>
      socket.emit 'onlineFriendsList', onlineFriendIds
}
