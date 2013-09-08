q = require('q')
_ = require('lodash')


class MpNotificationService

  constructor: (redis, socketIo, pg) ->
    @redisClient   = redis.createClient()
    @subscriber    = redis.createClient()
    @sockets       = socketIo.sockets
    @pgConnectionString = "pg://map-project@localhost/map-project_development"
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
        switch data.type
          when 'addFriendRequest'
            receiverClient = @onlineClients[data.receiver]
            if receiverClient
              for socket in receiverClient.sockets
                socket.emit 'serverData', data


    # --- Socket.io connection ---
    @sockets.on 'connection', (socket) =>
      # connection
      console.log "--> User #{socket.handshake.user.id} connected"
      @queryPg('SELECT * FROM users WHERE id = $1;', [socket.handshake.user.id])
      .then (results) =>
        user = results[0]
        @addToOnlineClient(user, socket).then (clientData) =>
          # onlineFriendsList event also serve as server ready indicator
          socket.clientData = clientData
          socket.emit 'onlineFriendsList', clientData.getOnlineFriends()

      # request online friends list
      socket.on 'requestOnlineFriendsList', (data, done) ->
        done(socket.clientData.getOnlineFriends())






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
        else
          client.query sqlQuery, (error, results) ->
            if error
              console.log('--> Postgre query error: ', error)
              queryFinished.reject()
              done()
            else
              queryFinished.resolve(results.rows)

    return queryFinished.promise


  # --- Oneline Client Management ---
  addToOnlineClient: (user, socket) ->
    userFetched = q.defer()
    clientData = @onlineClients[user.id]
    if clientData
      clientData.sockets.push socket
      userFetched.resolve(clientData)
    else
      that = this
      clientData = {
        user:         user
        sockets:     [socket]
        friendsList: []
        getOnlineFriends: ->
          _.filter @friendsList, (value, index) ->
            that.onlineClients[value]
      }
      @queryPg('SELECT * FROM friendships WHERE user_id = $1', [user.id])
      .then (friendships) ->
        clientData.friendsList = _.pluck(friendships, 'friend_id')
        userFetched.resolve(clientData)
      @onlineClients[user.id] = clientData

    return userFetched.promise







# Export module
module.exports = MpNotificationService
