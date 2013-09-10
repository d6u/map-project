###
MpNotification
###

app.service 'MpNotification',
['$rootScope', '$timeout', '$q', 'Restangular', '$route', 'socket', 'MpFriends', class MpNotification

  constructor: ($rootScope, $timeout, $q, @Restangular, $route, socket, @MpFriends) ->
    @notifications = []

    # --- Resouces ---
    @$$notifications = Restangular.all 'notifications'

    # --- Socket.io ---
    socket.on 'serverData', (serverData) =>
      @processServerData(serverData)


  # --- Login/out process management ---
  initialize: (scope) ->
    @getNotifications()

  destroy: ->
    @notifications = []


  # --- Incoming server notices management ---

  # directNotificationNames holds notice type that will be added to
  #   @notifications array directive when arrives from server
  directNotificationNames: [
    'addFriendRequest'
    'addFriendRequestAccepted'
    'projectInvitation'
    'projectInvitationAccepted'
    'projectInvitationRejected'
    'youAreRemovedFromProject'
    'projectDeleted'
  ]

  processServerData: (data) ->
    if _.indexOf(@directNotificationNames, data.type) >= 0
      newNotice = @Restangular.one('notifications', data.id)
      angular.extend(newNotice, data)
      @notifications.push newNotice

    # specific actions
    switch data.type
      when 'addFriendRequestAccepted'
        @MpFriends.addUserToFriendsList(data.sender)


  # --- Notification interface ---
  getNotifications: ->
    @$$notifications.getList().then (notifications) =>
      if @notifications.length
        # TODO: organize new and existing notifications
        @notifications = notifications
      else
        @notifications = notifications

  removeNotice: (notice) ->
    @notifications = _.without(@notifications, notice)

  # --- Special notice management ---
  # friend request
  acceptFriendRequest: (request) ->
    request.customPOST({}, 'accept_friend_request', {friendship_id: request.body.friendship_id})
    @removeNotice(request)
    @MpFriends.addUserToFriendsList(request.sender)

  ignoreFriendRequest: (request) ->
    request.customDELETE('ignore_friend_request', {friendship_id: request.body.friendship_id})
    @removeNotice(request)


  # --- Helpers ---
  sendClientData: (data) ->
    socket.emit 'clientData', data
]