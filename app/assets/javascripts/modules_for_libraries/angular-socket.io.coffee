app = angular.module 'angular-socket.io', []


# socket
app.provider 'socket', class

  # config
  setServerUrl: (@serverUrl) ->

  setHandshakeQuery: (handshakeQuery) ->
    queryArray = ("#{key}=#{value}" for key, value of handshakeQuery)
    @handshakeQuery = {query: queryArray.join('&')}

  # factory
  $get: ['$rootScope', '$timeout', '$q', ($rootScope, $timeout, $q) ->

    socketReady = $q.defer()

    # regular
    socketService =
      socket: if @serverUrl then io.connect(@serverUrl, @handshakeQuery) else io.connect(undefined, @handshakeQuery)

      on: (eventName, callback) ->
        @socket.on eventName, (args...) ->
          $timeout -> callback.apply(@socket, args)

      emit: (eventName, data, callback) ->
        @socket.emit eventName, data, (args...) =>
          $rootScope.$apply => callback.apply(@socket, args) if callback

    # resolver
    socketService.on 'connect', ->
      socketReady.resolve socketService

    # return
    socketReady.promise
  ]
