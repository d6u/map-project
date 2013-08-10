app = angular.module 'angular-mp.api', ['restangular']


# MpProjects
# ========================================
app.factory 'MpProjects', ['Restangular', '$rootScope', 'TheMap', '$location',
(Restangular, $rootScope, TheMap, $location) ->

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
        @projects = _.union @projects, projects
        @__projects = _.clone(MpProjects.projects)


  # events
  $rootScope.$on '$routeChangeSuccess', (event, current, previous) ->
    # debugger
    # arrive directly
    if !previous
      # in
      if $rootScope.User.checkLogin()
        MpProjects.getProjects({include_participated: true}).then ->
          # AllProjectsViewCtrl
          if current.$$route.controller == 'AllProjectsViewCtrl'
            if MpProjects.projects.length == 0 then $location.path '/new_project'
          # NewProjectViewCtrl
          else if current.$$route.controller == 'NewProjectViewCtrl'
            if MpProjects.projects.length == 0
              $projects.post({title: 'last unsaved project'}).then (project) ->
                MpProjects.projects.push project
                MpProjects.currentProject = project
            else
              project = _.find MpProjects.projects, {title: 'last unsaved project'}
              # no project named 'last unsaved project' then create one
              if !project
                $projects.post({title: 'last unsaved project'}).then (project) ->
                  MpProjects.projects.push project
                  MpProjects.currentProject = project
                  MpProjects.currentProject.places = []
              # has project named 'last unsaved project'
              else
                MpProjects.currentProject = project
                project.getList('places').then (places) ->
                  MpProjects.__currentProjectPlaces = places
                  MpProjects.currentProject.places = places
          # ProjectViewCtrl
          else if current.$$route.controller == 'ProjectViewCtrl'
            project = _.find MpProjects.projects, {id: Number(current.params.project_id)}
            if !project
              $location.path('/all_projects') # TODO: promote to create one
            else
              MpProjects.currentProject = project
              project.getList('places').then (places) ->
                MpProjects.__currentProjectPlaces = places
                MpProjects.currentProject.places = places
    # not directly
    else
      # in
      if $rootScope.User.checkLogin()
        # from OutsideViewCtrl
        if previous.$$route.controller == 'OutsideViewCtrl'
          # to NewProjectViewCtrl
          if current.$$route.controller == 'NewProjectViewCtrl'
            # arrived without any unsaved place
            if MpProjects.currentProject.places.length == 0
              MpProjects.getProjects({include_participated: true}).then ->
                if MpProjects.projects.length == 0
                  $projects.post({title: 'last unsaved project'}).then (project) ->
                    MpProjects.projects.push project
                    MpProjects.currentProject = project
                else
                  project = _.find MpProjects.projects, {title: 'last unsaved project'}
                  # no project named 'last unsaved project' then create one
                  if !project
                    $projects.post({title: 'last unsaved project'}).then (project) ->
                      MpProjects.projects.push project
                      MpProjects.currentProject = project
                      MpProjects.currentProject.places = []
                  # has project named 'last unsaved project'
                  else
                    MpProjects.currentProject = project
                    project.getList('places').then (places) ->
                      MpProjects.__currentProjectPlaces = places
                      MpProjects.currentProject.places = places
            # arrived with unsaved places
            else
              MpProjects.getProjects({include_participated: true})
              _places = MpProjects.currentProject.places
              MpProjects.currentProject.places = []
              $projects.post({title: 'last unsaved project'}).then (project) ->
                MpProjects.projects.push project
                MpProjects.currentProject = project
                MpProjects.currentProject.places = _places
          # to Other
          else
            MpProjects.getProjects({include_participated: true}).then ->
              # to AllProjectsViewCtrl
              if current.$$route.controller == 'AllProjectsViewCtrl'
                if MpProjects.projects.length == 0 then $location.path '/new_project'
              # to ProjectViewCtrl
              else if current.$$route.controller == 'ProjectViewCtrl'
                project = _.find MpProjects.projects, {id: Number(current.params.project_id)}
                if !project
                  $location.path('/all_projects') # TODO: promote to create one
                else
                  MpProjects.currentProject = project
                  project.getList('places').then (places) ->
                    MpProjects.__currentProjectPlaces = places
                    MpProjects.currentProject.places = places
        # from Other
        else
          # to AllProjectsViewCtrl
          if current.$$route.controller == 'AllProjectsViewCtrl'
            if MpProjects.projects.length == 0 then $location.path '/new_project'
          # to NewProjectViewCtrl
          else if current.$$route.controller == 'NewProjectViewCtrl'
            if MpProjects.projects.length == 0
              $projects.post({title: 'last unsaved project'}).then (project) ->
                MpProjects.projects.push project
                MpProjects.currentProject = project
            else
              project = _.find MpProjects.projects, {title: 'last unsaved project'}
              # no project named 'last unsaved project' then create one
              if !project
                $projects.post({title: 'last unsaved project'}).then (project) ->
                  MpProjects.projects.push project
                  MpProjects.currentProject = project
                  MpProjects.currentProject.places = []
              # has project named 'last unsaved project'
              else
                MpProjects.currentProject = project
                project.getList('places').then (places) ->
                  MpProjects.__currentProjectPlaces = places
                  MpProjects.currentProject.places = places
          # to ProjectViewCtrl
          else if current.$$route.controller == 'ProjectViewCtrl'
            project = _.find MpProjects.projects, {id: Number(current.params.project_id)}
            if !project
              $location.path('/all_projects') # TODO: promote to create one
            else
              MpProjects.currentProject = project
              project.getList('places').then (places) ->
                MpProjects.__currentProjectPlaces = places
                MpProjects.currentProject.places = places
      else
        MpProjects.reset()


  # ----------------------------------------
  # watch for changes in currentProject.places
  $rootScope.$watch (->
    return _.pluck MpProjects.currentProject.places, 'id'
  ), ((newVal, oldVal) ->
    if !$rootScope.User || !$rootScope.User.checkLogin()
      MpProjects.__currentProjectPlaces = _.clone MpProjects.currentProject.places
      return
    newPlaces     = _.difference MpProjects.currentProject.places, MpProjects.__currentProjectPlaces
    oldPlaces     = _.difference MpProjects.__currentProjectPlaces, MpProjects.currentProject.places
    changedPlaces = _.filter MpProjects.currentProject.places, (val, idx) ->
      if val.order != idx then val.order = idx; return true else return false
    # actions
    _.forEach newPlaces, (val, idx) ->
      _marker = val.$$marker
      delete val.$$marker
      MpProjects.currentProject.all('places').post(val).then (place) ->
        angular.extend val, place
      val.$$marker = _marker
    _.forEach oldPlaces, (val, idx) ->
      if val.remove
        delete val.$$marker
        val.remove()
    _.forEach changedPlaces, (val, idx) ->
      if val.put
        _marker = val.$$marker
        delete val.$$marker
        val.put()
        val.$$marker = _marker
    # clone
    MpProjects.__currentProjectPlaces = _.clone MpProjects.currentProject.places
  ), true

  # watch for changes in projects, remove the missing one from server
  $rootScope.$watch ((currentScope) ->
    return _.pluck(MpProjects.projects, 'id').sort()
  ), ((newVal, oldVal, currentScope) ->
    if !$rootScope.User || !$rootScope.User.checkLogin() then return
    missingProject = _.difference oldVal, newVal
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
