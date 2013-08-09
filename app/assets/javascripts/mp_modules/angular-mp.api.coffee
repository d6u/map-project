app = angular.module 'angular-mp.api', ['restangular']


# MpProjects
# ========================================
app.factory 'MpProjects', ['Restangular', '$rootScope',
(Restangular, $rootScope) ->

  # REST /projects/:id
  Restangular.addElementTransformer 'projects', true, (projects) ->
    projects.addRestangularMethod 'find_by_title', 'get', '', {title: 'last unsaved project'}
    return projects

  Restangular.addElementTransformer 'projects', false, (project) ->
    return project

  $projects = Restangular.all 'projects'

  # Object structure
  MpProjects =
    projects: []
    __projects: []
    currentProject: {places: []}
    __currentProjectPlaces: []
    clean: ->
      @currentProject = {places: []}
      @__currentProjectPlaces = []
    reset: ->
      @projects = []
      @__projects = []
      @currentProject = {places: []}
      @__currentProjectPlaces = []
    getProjects: (queryParams) ->
      $projects.getList(queryParams).then (projects) =>
        @projects = projects
        @__projects = _.clone(MpProjects.projects)

  # watch for changes in currentProject.places
  $rootScope.$watch ((currentScope) ->
    lengthDiff = MpProjects.currentProject.places.length - MpProjects.__currentProjectPlaces.length
    # list sorting
    if lengthDiff == 0
      changedPlaces = []
      for place, index in MpProjects.currentProject.places
        place.$$marker.setIcon {url: "/assets/number_#{index}.png"}
        if place.order != index
          place.order = index
          changedPlaces.push place
      return if changedPlaces.length > 0 then changedPlaces else undefined
    # add
    else if lengthDiff > 0
      for place, index in MpProjects.currentProject.places
        if place != MpProjects.__currentProjectPlaces[index]
          place.$$index == index
          return place
    # remove
    else if lengthDiff < 0
      for place, index in MpProjects.__currentProjectPlaces
        if place != MpProjects.currentProject.places[index]
          place.$$needRemove = true
          return place
      # $rootScope.$broadcast 'placeRemovedFromList', place
    return
  ), ((newVal, oldVal, currentScope) ->
    if newVal
      MpProjects.__currentProjectPlaces = _.clone(MpProjects.currentProject.places)
      if $rootScope.User && $rootScope.User.checkLogin()
        if angular.isArray newVal
          places = newVal
          place.put() for place in places
        else
          place = newVal
          if place.$$needRemove
            place.remove()
          else
            MpProjects.currentProject.places.post(place).then (place) ->
              console.log 'new place posted', MpProjects.currentProject.places, place
  )


  # watch for changes in projects
  $rootScope.$watch ((currentScope) ->
    lengthDiff = MpProjects.projects.length - MpProjects.__projects.length
    # remove
    if lengthDiff < 0
      for project, index in MpProjects.__projects
        if project != MpProjects.projects[index]
          project.$$needRemove = true
          return project
    return
  ), ((newVal, oldVal, currentScope) ->
    if newVal
      MpProjects.__projects = _.clone(MpProjects.projects)
      project = newVal
      if project.$$needRemove
        project.remove()
  )

  #
  return MpProjects
]


# friendships
app.factory 'Friendship', ['Restangular', (Restangular) ->

  Restangular.all 'friendships'
]


# invitations
app.factory 'Invitation', ['$http', ($http) ->

  generate: (project_id)->
    postBody =
      invitation: {project_id: project_id}
    $http.post('/invitation/generate', postBody).then (response) -> response.data.code
]
