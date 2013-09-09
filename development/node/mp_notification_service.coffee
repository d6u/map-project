q = require('q')
_ = require('lodash')


# --- Module ---
class MpNotificationService

  constructor: (redis, socketIo, pg) ->
    @redisClient   = redis.createClient()
    @subscriber    = redis.createClient()
    @sockets       = socketIo.sockets
    @pgConnectionString = "postgres://map-project:1234@localhost/map-project_development"
    @pg            = pg
    @onlineClients = {}


    # --- Redis pub/sub ---
    @subscriber.subscribe 'notice_channel'
    @subscriber.on 'subscribe', (channel, count) ->
      console.log "==> MpNotificationService subscribed #{channel}, subscribed #{count} channels in total"

    # sub message
    @subscriber.on 'message', (channel, message) =>
      console.log '--> Redis receive message: ', message
      if channel == 'notice_channel'
        data = JSON.parse(message)
        receiverClient = @onlineClients[data.receiver]
        if receiverClient
          for socket in receiverClient.sockets
            socket.emit 'serverData', data


    # --- Socket.io connection ---
    @sockets.on 'connection', (socket) =>
      # connection
      console.log "--> User #{socket.handshake.user.id} connected"
      @addToOnlineClient(socket).then (clientData) =>
        # onlineFriendsList event also serve as server ready indicator
        socket.emit 'onlineFriendsList', @getOnlineFriends(clientData)

      # request online friends list
      socket.on 'requestOnlineFriendsList', (data, done) =>
        done(@getOnlineFriends(@getClientData(socket)))

      # disconnect
      socket.on 'disconnect', =>
        console.log "--> User #{socket.handshake.user.id} disconnected"
        @removeClientFromOnlineList(socket)


  # --- Pg interface ---
  queryPg: (sqlQuery, params) ->
    queryFinished = q.defer()
    @pg.connect @pgConnectionString, (error, client, done) ->
      if error
        console.log('--> Postgre connection error: ', error)
        queryFinished.reject()
        done()
      else
        if params
          client.query sqlQuery, params, (error, results) ->
            if error
              console.log('--> Postgre query error: ', error)
              queryFinished.reject()
              done()
            else
              queryFinished.resolve(results.rows)
              done()
        else
          client.query sqlQuery, (error, results) ->
            if error
              console.log('--> Postgre query error: ', error)
              queryFinished.reject()
              done()
            else
              queryFinished.resolve(results.rows)
              done()

    return queryFinished.promise


  # --- Oneline Client Management ---
  addToOnlineClient: (socket) ->
    userFetched = q.defer()
    user        = socket.handshake.user
    clientData  = @getClientData(socket)
    if clientData
      clientData.sockets.push socket
      userFetched.resolve(clientData)
    else
      clientData = {
        user:         user
        sockets:     [socket]
        friendsList: []
      }
      @onlineClients[user.id] = clientData
      @queryPg('SELECT * FROM friendships WHERE user_id = $1', [user.id])
      .then (friendships) ->
        clientData.friendsList = _.pluck(friendships, 'friend_id')
        userFetched.resolve(clientData)

    return userFetched.promise


  removeClientFromOnlineList: (socket) ->
    clientData = @getClientData(socket)
    if clientData
      clientData.sockets = _.without clientData.sockets, socket
      if !clientData.sockets.length
       delete @onlineClients[socket.handshake.user.id]


  getClientData: (socket) ->
    @onlineClients[socket.handshake.user.id]


  getOnlineFriends: (clientData) ->
    _.filter clientData.friendsList, (friend_id) =>
      @onlineClients[friend_id]


# Export module
module.exports = MpNotificationService
