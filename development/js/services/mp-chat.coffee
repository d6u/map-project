app.service 'MpChat',
['socket', 'TheProject', '$routeSegment', class MpChat

  constructor: (@socket, @TheProject, @$routeSegment) ->


  # --- Enter/leave project view management ---
  initialize: (scope) ->
    scope.$on '$routeChangeSuccess', (event) =>
      if !@$routeSegment.contains('project')
        @destroy()

    @socket.on 'chatMessage', (data) ->
      # TODO: add message to chat history

  destroy: ->


  # --- Real time messaging helper ---
  sendChatMessage: (message) ->
    @socket.emit 'chatMessage', {
      message: message
      project_id: @TheProject.project.id
    }
]
