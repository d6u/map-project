angular.module('md-socket-io', [])
.provider 'socket', ->

  setSocketServer: (@$$socketServer) ->

  setHandshakeQuery: (handshakeQuery)  ->
    queryArray = ("#{key}=#{value}" for key, value of handshakeQuery)
    @handshakeQuery = queryArray.join('&')


  # Factory
  $get: ['$timeout', '$rootScope', '$q', ($timeout, $rootScope, $q) ->

    # --- Init ---
    [socketServer, handshakeQuery] = [@$$socketServer, @handshakeQuery]
    socketOptions  = {
      query:          handshakeQuery
      'auto connect': false
    }


    # --- Socket.io ---
    return {
      $$socket: io.connect(socketServer, socketOptions)

      on: (eventName, callback) ->
        @$$socket.on eventName, (args...) ->
          $timeout ->
            callback.apply(@$$socket, args)

      emit: (eventName, data, callback) ->
        @$$socket.emit eventName, data, (args...) =>
          $rootScope.$apply =>
            callback.apply(@$$socket, args) if callback

      connect: ->
        socketConnected = $q.defer()
        @$$socket.socket.connect()
        @on 'connect', =>
          socketConnected.resolve()
        return socketConnected.promise

      disconnect: ->
        @$$socket.removeAllListeners()
        @$$socket.disconnect()
    }
  ]
