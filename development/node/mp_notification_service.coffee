q          = require('q')
_          = require('lodash')
redis      = require('redis')
pgQuery    = require('./pg_query_helper')
MpUserNode = require('./mp_user_node')
filterUser = require('./filter_user')


# --- Module ---
class MpNotificationService

  constructor: (socketIo) ->
    @redisClient   = redis.createClient()
    @subscriber    = redis.createClient()
    @sockets       = socketIo.sockets
    @onlineClients = {}
    MpUserNode.setSockets(@sockets)


    # --- Redis pub/sub ---
    @subscriber.subscribe 'notice_channel'
    @subscriber.on 'subscribe', (channel, count) ->
      console.log "==> MpNotificationService subscribed #{channel}, subscribed #{count} channels in total"

    # sub message
    @subscriber.on 'message', (channel, message) =>
      console.log '--> Redis receive message: ', message
      if channel == 'notice_channel'
        data = JSON.parse(message)
        MpUserNode.pushMessageToUserId data.receiver_id, 'serverData', data,
        (socket, eventName, data) ->
          switch data.type
            when 'addFriendRequestAccepted'
              MpUserNode.pushOnlineFriendIds(socket)


    # --- Socket.io connection ---
    @sockets.on 'connection', (socket) =>
      # connection
      console.log "--> User #{socket.handshake.user.id} connected"
      MpUserNode.addSocketToUserNode socket
      MpUserNode.pushOnlineFriendIds socket

      # request online friends list
      socket.on 'requestOnlineFriendsList', (data, done) ->
        MpUserNode.getOnlineFriendIds(socket).then (ids) ->
          done(ids)

      # disconnect
      socket.on 'disconnect', ->
        console.log "--> User #{socket.handshake.user.id} disconnected"
        MpUserNode.removeSocketFromUserNode socket

      # chating
      socket.on 'chatMessage', (chatMessage) ->
        messageData = {
          type:    'chatMessage'
          sender:  filterUser(socket.handshake.user)
          message: chatMessage.message
        }
        MpUserNode.broadcastMessageOfProject(chatMessage.project_id, messageData, socket)
  # --- END constructor ---


# Export module
module.exports = MpNotificationService
