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

    destroy: ->
      @projects = []

    getProjects: (queryParams={include_participated: true}) ->
      @gettingProjects = MpProjects.$$projects.getList(queryParams).then (projects) =>
        @projects = projects
        return projects

    createProject: (project={}) ->
      if !project.title
        project.title = 'last unsaved project'
      return @$$projects.post(project).then (project) =>
        @projects.push project
        return project

    # will return a promise which resolve into a project
    # reject if no project for provided id
    findProjectById: (id) ->
      _id   = Number(id)
      found = $q.defer()
      # if projects still in the process of GET data from server, this operation will wait
      # this situation normally happends when user login directly navigate into project view
      @gettingProjects.then =>
        target = _.find(@projects, {id: _id})
        if target
          found.resolve(target)
        # double check on server if no project found on local
        else
          Restangular.one('projects', _id).get().then ((project) ->
            # found a project on server means local copies are not complete, local needs to update
            found.resolve(project)
            MpProjects.projects.push(project)
            # TODO: update local
          ), ->
            found.reject()

      return found.promise

    updateProject: (project) ->
      _id = project.id
      delete project.id
      _project = _.find @projects, {id: _id}
      angular.extend _project, project
      _project.put()

    removeProject: (project) ->
      @projects = _.without @projects, project
      project.remove()
  }


  # return
  # ----------------------------------------
  return MpProjects
]
