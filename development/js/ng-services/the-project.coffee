app.service 'TheProject',
['Restangular', 'MpFriends', 'MpUser', 'MpProjects', 'socket', '$routeSegment', class TheProject

  constructor: (@Restangular, @MpFriends, @MpUser, @MpProjects, socket, @$routeSegment) ->
    @project           = {}
    @places            = []
    @participatedUsers = []

    # update project participating users when user list changed
    socket.on 'serverData', (notice) =>
      if notice.type in ['projectInvitationAccepted', 'newUserAdded'] &&
      notice.body.project.id == @project.id
        @getParticipatedUsers()

      else if notice.type == 'placeAdded' && notice.sender.id != MpUser.getId()
        newPlace = Restangular.one('projects', @project.id).one('places', notice.place.id)
        angular.extend newPlace, notice.place
        @places.push newPlace


  # --- Enter/leave project view management ---
  initialize: (scope, projectId) ->
    @project           = {}
    @places            = []
    @participatedUsers = []

    loadCurrentProject = =>
      @MpProjects.findProjectById(projectId).then ((project) =>
        @project  = project
        @$$places = @Restangular.one('projects', project.id).all('places')
        @getPlaces()
        @getParticipatedUsers()
      ), =>
        # TODO: handle error, e.g. project is not authorized to view

    # Project retrieve, if no projectId, will use an empty object
    if projectId
      if @MpProjects.$initializing?
        @MpProjects.$initializing.then loadCurrentProject
      else
        loadCurrentProject()

    scope.$on '$destroy', (event) =>
      @destroy()


  destroy: ->
    @project           = {}
    @places            = []
    @participatedUsers = []


  # Places
  # ----------------------------------------
  # query places list from server
  getPlaces: ->
    if @project.id
      @$$places.getList().then (places) =>
        @places = places

  # will remove the marker from the map first, map directive will create a
  #   new marker for it, once it is added to this.places
  addPlace: (place) ->
    place.order = @places.length
    @places.push place
    if @project.id
      @$$places.post(place).then (_place) ->
        angular.extend place, _place

  # place have to be a object contains id, and other updated attributes
  #   it is suggested that place object to be simple with no methods
  updatePlace: (place) ->
    _place = _.find @places, {id: place.id}
    angular.extend _place, place
    if @project.id
      _place.put()

  # place can be a id or place object
  removePlace: (place) ->
    if angular.isNumber place
      place = _.find @places, {id: place}
    @places = _.without @places, place
    place.$$marker.setMap null
    delete place.$$marker
    if @project.id
      place.remove()

  # Participated users
  # ----------------------------------------
  ###
  If user is a friend, object from friends property will be referred,
    otherwise will refer to object in returned by server
  ###
  participatedUsers: []

  getParticipatedUsers: ->
    @Restangular.one('projects', @project.id).customGETLIST('participating_users')
    .then (users) =>
      @organizeParticipatedUsers(users)

  # users is an array contains user object, each object must have `id`
  addParticipatedUsers: (users) ->
    ids = _.pluck(users, 'id')
    @Restangular.one('projects', @project.id)
    .customPOST({}, 'add_users', {user_ids: ids.join(',')})

  # organize server returned participated users
  organizeParticipatedUsers: (users) ->
    @participatedUsers = []
    for user, index in users
      friend = _.find @MpFriends.friends, {id: user.id}
      if friend
        @participatedUsers.push friend
      else if user.id != @MpUser.getId()
        @participatedUsers.push user

  removeParticipatingUser: (user) ->
    @Restangular.one('projects', @project.id)
    .customDELETE('remove_users', {user_ids: user.id})
    @participatedUsers = _.without(@participatedUsers, user)


  # Project
  # ----------------------------------------
  # project object should not contain id
  updateProject: (project) ->
    angular.extend @project, project
    @project.put()


  # --- Outside View Places Saving ---
  savePlacesOfProject: (places, project) ->
    $places = project.all('places')
    allPlacesSaved = []
    for place in places
      allPlacesSaved.push $places.post(place)
    return allPlacesSaved
]