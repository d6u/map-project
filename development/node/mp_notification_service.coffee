q          = require('q')
_          = require('lodash')
redis      = require('redis')
pgQuery    = require('./pg_query_helper')
MpUserNode = require('./mp_user_node')


###
onlineClients = [clientData...]

clientData = {
  user:         user
  sockets:     [socket]
  friendsList: []
}
###

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
        clientData = @onlineClients[data.receiver]
        if clientData
          for socket in clientData.sockets
            socket.emit 'serverData', data
          # specific actions
          switch data.type
            when 'addFriendRequestAccepted'
              @pushOnlineFriendsDataToClient(clientData)
              senderClientData = @onlineClients[data.sender.id]
              if senderClientData
                @pushOnlineFriendsDataToClient(senderClientData)



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
  # --- END constructor ---


# Export module
module.exports = MpNotificationService
