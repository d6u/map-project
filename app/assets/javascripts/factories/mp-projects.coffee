###
MpProjects handles project query/create/update/delete
###

app.factory 'MpProjects',
['Restangular', '$rootScope', '$q',
( Restangular,   $rootScope,   $q) ->

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
    $$projects: $projects
    projects:   []
    __projects: []

    resetAll: ->
      @projects   = []
      @__projects = []

    getProjects: (queryParams) ->
      $projects.getList(queryParams).then (projects) =>
        _projects = @projects
        @projects = projects
        newProjectsIds = _.pluck(projects, 'id')
        oldProjectsIds = _.pluck(_projects, 'id')
        remainingProjectsIds = _.difference(oldProjectsIds, newProjectsIds)
        _.forEach remainingProjectsIds, (id) =>
          project = _.find(_projects, {id: id})
          @projects.push project
        @__projects = _.clone MpProjects.projects
        return projects

    createProject: (project) ->
      if !project
        project = {}
      if !project.title
        project.title = 'last unsaved project'
      return @$$projects.post(project).then (project) =>
        @projects.push project
        return project

    findProjectById: (id) ->
      found = $q.defer()
      _id = Number(id)
      found.resolve(_.find @projects, {id: _id})
      return found.promise

    updateProject: (project) ->
      _id = project.id
      delete project.id
      _project = _.find @projects, {id: _id}
      angular.extend _project, project
      _project.put()
  }


  # return
  # ----------------------------------------
  return MpProjects
]
