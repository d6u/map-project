app = angular.module 'angular-mp.api', ['restangular']


# MpProjects
# ========================================
app.factory 'MpProjects', ['Restangular', '$rootScope', 'TheMap',
(Restangular, $rootScope, TheMap) ->

  # REST /projects/:id
  Restangular.addElementTransformer 'projects', true, (projects) ->
    projects.addRestangularMethod 'find_by_title', 'get', '', {title: 'last unsaved project'}
    return projects

  Restangular.addElementTransformer 'projects', false, (project) ->
    return project

  $projects = Restangular.all 'projects'

  # Object structure
  MpProjects =
    $$projects: $projects
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
    setCurrentProject: (project) ->
      @currentProject = project
      @currentProject.places = []
      @__currentProjectPlaces = []
      @currentProject.getList('places').then (places) =>
        @currentProject.places = places
        @__currentProjectPlaces = _.clone(@currentProject.places)
        TheMap.mapReady.promise.then ->
          for place in places
            coordMatch = /\((.+), (.+)\)/.exec place.coord
            latLog = new google.maps.LatLng coordMatch[1], coordMatch[2]
            markerOptions =
              map: TheMap.map
              title: place.name
              position: latLog
              icon:
                url: "/assets/number_#{place.order}.png"
            place.$$marker = new google.maps.Marker markerOptions


  # watch for changes in currentProject.places
  $rootScope.$watch (->
    return _.pluck MpProjects.currentProject.places, 'id'
  ), ((newVal, oldVal) ->
    newPlaces     = _.difference MpProjects.currentProject.places, MpProjects.__currentProjectPlaces
    oldPlaces     = _.difference MpProjects.__currentProjectPlaces, MpProjects.currentProject.places
    changedPlaces = _.filter MpProjects.currentProject.places, (val, idx) ->
      if val.order != idx then val.order = idx; return true else return false
    # actions
    if $rootScope.User && $rootScope.User.checkLogin()
      _.forEach newPlaces, (val, idx) ->
        _marker = val.$$marker
        delete val.$$marker
        MpProjects.currentProject.all('places').post(val).then (place) ->
          angular.extend val, place
        val.$$marker = _marker
      _.forEach oldPlaces, (val, idx) ->
        delete val.$$marker
        val.remove()
      _.forEach changedPlaces, (val, idx) ->
        _marker = val.$$marker
        delete val.$$marker
        val.put().then (rest) -> console.log rest, val
        val.$$marker = _marker
    # clone
    MpProjects.__currentProjectPlaces = _.clone MpProjects.currentProject.places
  ), true

  # watch for changes in projects, remove the missing one from server
  $rootScope.$watch ((currentScope) ->
    return _.pluck(MpProjects.projects, 'id').sort()
  ), ((newVal, oldVal, currentScope) ->
    missingProject = _.difference oldVal, newVal
    console.debug 'missing projects', missingProject
    for id in missingProject
      Restangular.one('projects', id).remove()
  ), true


  # return
  # ----------------------------------------
  return MpProjects
]


# invitations
app.factory 'Invitation', ['$http', ($http) ->

  generate: (project_id)->
    postBody =
      invitation: {project_id: project_id}
    $http.post('/invitation/generate', postBody).then (response) -> response.data.code
]
