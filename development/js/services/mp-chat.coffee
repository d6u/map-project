app.service 'MpChat',
['socket', 'TheProject', '$routeSegment', 'MpUser', class MpChat

  constructor: (@socket, @TheProject, @$routeSegment, @MpUser) ->
    @chatHistory = []


  # --- Enter/leave project view management ---
  initialize: (@scope) ->
    @chatHistory = []

    scope.$on '$destroy', (event) =>
      @destroy()

    @socket.on 'chatMessage', (data) =>
      @chatHistory.push data


  destroy: ->
    @socket.$$socket.removeAllListeners 'chatMessage'
    @chatHistory = []


  # --- Real time messaging helper ---
  sendChatMessage: (message) ->
    @scope.$apply =>
      @chatHistory.push {
        type:    'chatMessage'
        sender:  @MpUser.getUser()
        message: message
        $self:   true
      }
    @socket.emit 'chatMessage', {
      message: message
      project_id: @TheProject.project.id
    }
]
