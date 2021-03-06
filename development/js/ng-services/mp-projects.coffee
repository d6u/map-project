###
MpProjects handles project CRUD (create/read/update/delete)
###


app.service 'MpProjects',
['$q','Backbone','$http',
( $q,  Backbone,  $http) ->


  # --- Model ---
  Project = Backbone.Model.extend {

    initialize: (attrs, options) ->
      @set({title: 'Untitled map'}) if !attrs.title?
  }


  # --- Collection ---
  MpProjects = Backbone.Collection.extend {

    # --- Properties ---
    model:       Project
    comparator: 'updated_at'
    url:        '/api/projects'


    # --- Init ---
    initialize: () ->
      @on 'destroy', (model) =>
        @remove(model)


    initService: (scope) ->
      @fetch({
        reset: true
        success: =>
          @enter('service:ready')
      })
      @destroyListenerDeregister = scope.$on('$destroy', => @resetService())


    resetService: ->
      @destroyListenerDeregister()
      delete @destroyListenerDeregister
      @reset()
      @leave('service:ready')


    # --- Custom Methods ---
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


    # return a promise of project model
    #
    createProject: (attrs={}) ->
      created = $q.defer()

      @create(attrs, {
        success: (project, responseData, options) ->
          created.resolve(project)
        error: ->
          created.reject()
      })

      return created.promise
  }
  # END MpProjects


  return new MpProjects
]
