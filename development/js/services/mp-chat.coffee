app.service 'MpChat',
['socket', 'TheProject', '$routeSegment', 'MpUser', 'MpFriends', class MpChat

  constructor: (@socket, @TheProject, @$routeSegment, @MpUser, @MpFriends) ->
    @chatHistory = []


  # --- Enter/leave project view management ---
  initialize: (@scope) ->
    @chatHistory = []

    scope.$on '$destroy', (event) =>
      @destroy()

    @socket.on 'chatMessage', (data) =>
      @chatHistory.push data

    scope.$watch (=>
      _.map @TheProject.participatedUsers.sort(), (friend) =>
        {id: friend.id, online: !!friend.$online}
    ), ((newVal, oldVal) =>
      return if !oldVal
      for friend, idx in @TheProject.participatedUsers
        if friend.$online != _.find(oldVal, {id: friend.id})?.online
          if friend.$online
            @chatHistory.push {
              type: 'userBehavior'
              message: "#{friend.name} comes online."
            }
          else
            @chatHistory.push {
              type: 'userBehavior'
              message: "#{friend.name} has gone offline."
            }
    ), true

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
