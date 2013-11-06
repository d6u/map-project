###
MpProjects handles project CRUD (create/read/update/delete)
###


app.service 'MpProjects',
['Restangular','$q','Backbone','$http','$afterLoaded','$afterDumped',
( Restangular,  $q,  Backbone,  $http,  $afterLoaded,  $afterDumped) ->


  # --- Model ---
  Project = Backbone.Model.extend {

    initialize: (attrs, options) ->
      @set({title: 'Untitled map'}) if !attrs.title?
  }


  # --- Collection ---
  MpProjects = Backbone.Collection.extend {

    # --- Properties ---
    afterLoaded:    $afterLoaded
    afterDumped:    $afterDumped
    $serviceLoaded: false

    model:       Project
    comparator: 'updated_at'
    url:        '/api/projects'


    # --- Init ---
    initialize: () ->
      @on('service:ready', => @$serviceLoaded = true)
      @on('service:reset', => @$serviceLoaded = false)
      @on 'destroy', (model) =>
        @remove(model)


    initService: (scope) ->
      @fetch({
        reset: true
        success: =>
          @trigger('service:ready')
      })
      @destroyListenerDeregister = scope.$on('$destroy', => @resetService())


    resetService: ->
      @destroyListenerDeregister()
      delete @destroyListenerDeregister
      @reset()
      @trigger('service:reset')


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
