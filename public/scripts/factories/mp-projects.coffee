# MpProjects
# ========================================
app.factory 'MpProjects', ['Restangular', '$rootScope',
(Restangular, $rootScope) ->

  # REST /projects/:id
  # addRestangularMethod (name, operation, path, params, headers, elementToPost)
  Restangular.addElementTransformer 'projects', true, (projects) ->
    projects.addRestangularMethod 'find_by_title', 'get', '', {title: 'last unsaved project'}
    return projects

  Restangular.addElementTransformer 'projects', false, (project) ->
    return project

  $projects = Restangular.all 'projects'

  ###
  properties start with `__` is a shallow clone of related property, this gives
    $watch the abilities to update the properties (if it's a array) by itself
  ###
  MpProjects = {
    $$projects:             $projects
    projects:               []
    __projects:             []
    currentProject:         {}
    currentProjectPlaces:   []
    __currentProjectPlaces: []

    resetCurrent: ->
      @currentProject         = {}
      @currentProjectPlaces   = []
      @__currentProjectPlaces = []

    resetAll: ->
      @projects   = []
      @__projects = []
      @resetCurrent()

    getProjects: (queryParams) ->
      $projects.getList(queryParams).then (projects) =>
        _projects = @projects
        @projects = projects
        newProjectsIds = _.pluck(projects, 'id')
        oldProjectsIds = _.pluck(_projects, 'id')
        remainingProjectsIds = _.difference(oldProjectsIds, newProjectsIds)
        _.forEach remainingProjectsIds, (id) ->
          project = _.find(_projects, {id: id})
          @projects.push project
        @__projects = _.clone MpProjects.projects
        return projects

    removePlace: (place) ->
      place.$$marker.setMap null
      @currentProjectPlaces = _.without @currentProjectPlaces, place
  }

  # watchers
  # ----------------------------------------
  # $watch for changes in projects, delete the removed one from server
  $rootScope.$watch (->
    return _.pluck(MpProjects.projects, 'id').sort()
  ), ((newVal, oldVal) ->
    if !$rootScope.User || !$rootScope.User.checkLogin()
      MpProjects.__projects = _.clone MpProjects.projects
      return
    removedProject = _.difference MpProjects.__projects, MpProjects.projects
    project.remove() for project in removedProject
    MpProjects.__projects = _.clone MpProjects.projects
  ), true

  # $watch for changes in currentProjectPlaces
  $rootScope.$watch (->
    return _.pluck MpProjects.currentProjectPlaces, 'id'
  ), ((newVal, oldVal) ->
    if !$rootScope.User || !$rootScope.User.checkLogin()
      MpProjects.__currentProjectPlaces = _.clone MpProjects.currentProjectPlaces
      return
    newPlaces     = _.difference MpProjects.currentProjectPlaces, MpProjects.__currentProjectPlaces
    oldPlaces     = _.difference MpProjects.__currentProjectPlaces, MpProjects.currentProjectPlaces
    changedPlaces = _.filter MpProjects.currentProjectPlaces, (val, idx) ->
      if val.order != idx then val.order = idx; return true else return false
    # actions
    _.forEach newPlaces, (val, idx) ->
      MpProjects.currentProject.all('places').post(val).then (place) ->
        angular.extend val, place
    _.forEach oldPlaces, (val, idx) ->
      val.remove()
    _.forEach changedPlaces, (val, idx) ->
      val.put()
    # clone
    MpProjects.__currentProjectPlaces = _.clone MpProjects.currentProjectPlaces
  ), true


  # return
  # ----------------------------------------
  return MpProjects
]
