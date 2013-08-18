###
TheProject is a class that will handle:
  project update, places query/create/update/delete
  note: project query/create/delete will be handled by MpProjects
###

app.factory 'TheProject',
['MpProjects', 'Restangular',
( MpProjects,   Restangular) ->

  # Return a class
  return class TheProject
    constructor: (projectId) ->
      if projectId
        MpProjects.findProjectById(projectId).then(
          ((project) =>
            @project = project
            @$$places = Restangular.one('projects', project.id).all('places')
            @getPlacesList()),
          (=>
            # TODO: handle error, e.g. project is not authorized to view
          )
        )
      else
        @places = []

    # query places list from server
    getPlacesList: ->
      @$$places.getList().then (places) =>
        @places = places

    # will remove the marker from the map first, map directive will create a
    #   new marker for it, once it is added to this.places
    addPlace: (place) ->
      place.order = @places.length
      @places.push place
      if @project
        @$$places.post(place).then (_place) ->
          angular.extend place, _place

    # place have to be object contains id, and other updated attributes
    #   it is suggested that place object to be simple with no methods
    updatePlace: (place) ->
      _id = place.id
      delete place.id
      _place = _.find @places, {id: _id}
      angular.extend _place, place
      if @project
        _place.put()

    # place can be a id or place object
    removePlace: (place) ->
      if angular.isNumber place
        place = _.find @places, {id: place}
      @places = _.without @places, place
      place.$$marker.setMap null
      delete place.$$marker
      if @project
        place.remove()

    # project object should not contain id
    updateProject: (project) ->
      angular.extend @project, project
      @project.put()
]
