###
MpProjects handles project query/create/update/delete
###

app.factory 'MpProjects',
['Restangular', '$rootScope', '$q',
( Restangular,   $rootScope,   $q) ->

  $projects = Restangular.all 'projects'
  $projects.addRestangularMethod 'find_by_title', 'get', '',
                                 {title: 'last unsaved project'}


  return class MpProjects

    constructor: ->
      @$$projects = $projects
      @projects   = []
      @getProjects()

    getProjects: (queryParams={include_participating: true}) ->
      @gettingProjects = @$$projects.getList(queryParams).then (projects) =>
        @projects = projects
        return projects

    createProject: (project={}) ->
      if !project.title
        project.title = 'last unsaved project'
      return @$$projects.post(project).then (project) =>
        @projects.unshift project
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
          Restangular.one('projects', _id).get().then ((project) =>
            # found a project on server means local copies are not complete, local needs to update
            found.resolve(project)
            @projects.push(project)
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
]
