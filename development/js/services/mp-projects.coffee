###
MpProjects handles project query/create/update/delete
###

app.service 'MpProjects',
['Restangular', '$q', class MpProjects

  constructor: (@Restangular, @$q) ->
    @projects   = []

    # --- Resouces ---
    @$$projects = Restangular.all 'projects'

    Restangular.addElementTransformer 'projects', true, (projects) =>
      projects.addRestangularMethod 'find_by_title', 'get', undefined, {title: 'last unsaved project'}
      return projects


  # --- Login/out process management ---
  initialize: (scope) ->
    @$initializing = @getProjects()
    @$initializing.then =>
      delete @$initializing


  # --- Project interface ---
  getProjects: (queryParams={include_participating: true}) ->
    @$$projects.getList(queryParams).then (projects) =>
      @projects = projects

  createProject: (project={}) ->
    if !project.title
      project.title = 'last unsaved project'
    return @$$projects.post(project).then (project) =>
      @projects.unshift project
      return project

  # will return a promise which resolve into a project,
  #   reject if no project for provided id
  findProjectById: (id) ->
    id     = Number(id)
    found  = @$q.defer()
    target = _.find(@projects, {id: id})
    if target
      found.resolve(target)
    # double check on server if no project found on local
    else
      @Restangular.one('projects', id).get().then ((project) =>
        # found a project on server means local copies are not complete,
        #   needs to update local copies
        found.resolve(project)
        @projects.push(project)
        # TODO: update local
      ), ->
        found.reject()

    return found.promise

  updateProject: (project) ->
    id = project.id
    delete project.id
    _project = _.find @projects, {id: id}
    angular.extend _project, project
    _project.put()

  removeProject: (project) ->
    @projects = _.without @projects, project
    project.remove()
]
