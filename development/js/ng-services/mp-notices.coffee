app.service 'MpNotices',
['socket','MpFriends','Backbone','$http',
( socket,  MpFriends,  Backbone,  $http) ->


  # --- Constants ---
  # directNotificationNames holds notice type that will be added to
  #   @notifications array directive when arrives from server
  DIRECT_NOTICE_TYPES = [
    'addFriendRequest'
    'addFriendRequestAccepted'
    'projectInvitation'
    'projectInvitationAccepted'
    'projectInvitationRejected'
    'newUserAdded'
    'youAreRemovedFromProject'
    'projectUserListUpated'
  ]


  # --- Model ---
  Notice = Backbone.Model.extend {

    initialize: ->
      senderId = @get('sender_id')
      friend = MpFriends.get(senderId)
      if friend?
        @sender = friend
      else
        sender = _.find(@collection.models, {sender: {id: senderId}})
        if sender?
          @sender = sender
        else
          $http.get("/api/users/#{senderId}").then (response) =>
            if response.status == 200
              @sender = response.data
  }


  # --- Collection ---
  MpNotices = Backbone.Collection.extend {

    model: Notice
    url: "/api/notices"
    comparator: 'created_at'


    initialize: ->
      @on 'add', ->
        console.debug arguments


    initService: (scope) ->
      @initializing = true
      @fetch({
        reset: true
        success: =>
          delete @initializing
      })

      addPushData = (data) =>
        @add(data)

      socket.on('pushData', addPushData)

      deregister = scope.$on '$destroy', =>
        @reset()
        socket.removeAllListeners('pushData', addPushData)
        deregister()
  }
  # END MpNotices


  return new MpNotices
]
