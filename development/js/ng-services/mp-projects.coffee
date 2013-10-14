###
MpProjects handles project CRUD (create/read/update/delete)
###


app.service 'MpProjects',
['Restangular','$q','Backbone','$http',
( Restangular,  $q,  Backbone,  $http) ->


  # --- Model ---
  Project = Backbone.Model.extend {

    initialize: (attrs, options) ->
      @set({title: 'Untitled map'}) if !attrs.title?
  }


  # --- Collection ---
  MpProjects = Backbone.Collection.extend {

    model: Project
    comparator: 'updated_at'
    url: '/api/projects'

    initialize: () ->
      @on 'destroy', (model) =>
        @remove(model)


    initService: (scope) ->
      @$scope = scope
      @fetch({reset: true})
      @initializing = true

      @once 'sync', =>
        delete @initializing


    findProjectById: (id) ->
      found   = $q.defer()
      project = @get(id)

      if project?
        found.resolve(project)
      else
        @fetch({
          success: =>
            project = @get(id)
            if project? then found.resolve(project) else found.reject()
        })

      return found.promise
  }
  # END MpProjects


  return new MpProjects
]
