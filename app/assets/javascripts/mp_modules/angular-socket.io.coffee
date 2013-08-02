angular.module('angular-socket.io', [])
.provider 'socket', class
  # config
  setServerUrl: (@serverUrl) ->
  setHandshakeQuery: (handshakeQuery) ->
    queryArray = ("#{key}=#{value}" for key, value of handshakeQuery)
    @handshakeQuery = {query: queryArray.join('&')}

  # factory
  $get: ['$rootScope', '$timeout', ($rootScope, $timeout) ->
    # regular
    socket: if @serverUrl then io.connect(@serverUrl, @handshakeQuery) else io.connect(undefined, @handshakeQuery)
    on: (eventName, callback) ->
      @socket.on eventName, (args...) ->
        $timeout (-> callback.apply(@socket, args)), 0

    emit: (eventName, data, callback) ->
      @socket.emit eventName, data, (args...) =>
        $rootScope.$apply => callback.apply(@socket, args) if callback

    # pub/sub
    subChannel: (channelId, subCallback, emitCallback) ->
      @emit('subChannel', channelId, emitCallback)
      @on('subMessage', subCallback)
    unsubChannel: (emitCallback) ->
      @emit('unsubChannel', {}, emitCallback)
      @socket.removeAllListeners('subMessage')
    pubChat: (message, callback) ->
      data = { type: 'message', body: message }
      @emit('pubMessage', data, callback)
    pubUserBehavior: (behavior, callback) ->
      data = { type: 'userBehavior', body: behavior }
      @emit('pubMessage', data, callback)
    pubPlace: (place, callback) ->
      # TODO
  ]
