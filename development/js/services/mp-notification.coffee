###
MpNotification
###

app.service 'MpNotification',
['$rootScope', '$timeout', '$q', 'Restangular', '$route', 'socket', 'MpFriends', 'MpProjects', class MpNotification

  constructor: ($rootScope, $timeout, $q, @Restangular, $route, socket, @MpFriends, @MpProjects) ->
    @notifications = []

    # --- Resouces ---
    @$$notifications = Restangular.all 'notifications'

    # --- Socket.io ---
    socket.on 'serverData', (serverData) =>
      @processServerData(serverData)


  # --- Login/out process management ---
  initialize: (scope) ->
    @getNotifications()

    scope.$on '$destroy', =>
      @destroy()


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
    # 'youAreRemovedFromProject'
    # 'projectDeleted'
  ]

  processServerData: (data) ->
    if _.indexOf(@directNotificationNames, data.type) >= 0
      newNotice = @Restangular.one('notifications', data.id)
      angular.extend(newNotice, data)
      @notifications.unshift newNotice


  # --- Notification interface ---
  getNotifications: ->
    @$$notifications.getList().then (notifications) =>
      if @notifications.length
        unqi = _.unqi(_.union(@notifications, notifications), 'id')
        @notifications = @Restangular.restangularizeCollection(undefined, unqi, 'notifications')
      else
        @notifications = notifications
      @notifications.sort (a, b) -> b.created_at - a.created_at


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

  # project invitation
  acceptProjectInvitation: (invitation) ->
    invitation.customPOST({}, 'accept_project_invitation', {project_participation_id: invitation.body.project_participation_id}).then =>
      @MpProjects.getProjects()
    @removeNotice(invitation)

  rejectProjectInvitation: (invitation) ->
    invitation.customDELETE('reject_project_invitation', {project_participation_id: invitation.body.project_participation_id})
    @removeNotice(invitation)


  # --- Helpers ---
  sendClientData: (data) ->
    socket.emit 'clientData', data
]
