app.service 'MpNotices',
['socket','MpFriends','Backbone','$http','$q','$timeout',
( socket,  MpFriends,  Backbone,  $http,  $q,  $timeout) ->


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

    ignoreFriendRequest: ->
      $http.delete("/api/notices/#{@id}/ignore_friend_request")
      @collection.remove(@)

    acceptFriendRequest: ->
      $http.post("/api/notices/#{@id}/accept_friend_request")
      @collection.remove(@)

    rejectProjectInvitation: ->
      $http.delete("/api/notices/#{@id}/reject_project_invitation")
      @collection.remove(@)

    acceptProjectInvitation: ->
      $http.post("/api/notices/#{@id}/accept_project_invitation")
      @collection.remove(@)
  }


  # --- Collection ---
  MpNotices = Backbone.Collection.extend {

    model: Notice
    url: "/api/notices"
    comparator: 'created_at'


    initialize: ->
      @on 'add', (notice) =>
        @findSender( notice.get('sender_id') ).then (sender) =>
          @assignSenderToModels(sender)

      @on 'destroy', (notice) =>
        @remove(notice)


    initService: (scope) ->
      @initializing = true
      @fetch({
        reset: true
        success: =>
          delete @initializing

          senderIds = _.uniq( @pluck('sender_id') )
          for id in senderIds
            @findSender(id).then (sender) =>
              @assignSenderToModels(sender)
      })

      addPushData = (data) =>
        @add(data)

      socket.on('pushData', addPushData)

      deregister = scope.$on '$destroy', =>
        @reset()
        socket.removeAllListeners('pushData', addPushData)
        deregister()


    # find sender through local data first, then on the server
    #   used to find the sender for each notice
    # return promise resolve into user data obj
    findSender: (id) ->
      found = $q.defer()

      friend = MpFriends.get(id)
      if friend?
        $timeout -> found.resolve(friend.attributes)
      else
        modelWithSender = _.find(@models, {sender: {id: id}})
        if sender?
          $timeout -> found.resolve(modelWithSender.sender)
        else
          $timeout ->
            $http.get("/api/users/#{id}").then (response) =>
              if response.status == 200
                found.resolve(response.data)

      return found.promise


    # assign sender data to model with same sender_id
    assignSenderToModels: (sender) ->
      for notice in @where({sender_id: sender.id})
        notice.sender = sender
  }
  # END MpNotices


  return new MpNotices
]
