# require Backbone.js


angular.module('ngBackbone', [])

# --- States Management ---
.factory('ServiceStates', [->
  return {
    while: (state, callback) ->
      @states = {} if !@states?
      if !@states[state]?
        @states[state] = false
      else if @states[state] == true
        callback()

      @_states = {}        if !@_states?
      @_states[state] = [] if !@_states[state]?
      @_states[state].push(callback)
      return


    whileNot: (state, callback) ->
      @states = {} if !@states?
      if !@states[state]?
        @states[state] = false
      if @states[state] == false
        callback()

      @_notStates = {}        if !@_notStates?
      @_notStates[state] = [] if !@_notStates[state]?
      @_notStates[state].push(callback)
      return


    enter: (state) ->
      @states = {} if !@states?
      if !@states[state]? || @states[state] != true
        @states[state] = true
        if @_states && @_states[state]?.length
          callback() for callback in @_states[state]
      return


    leave: (state) ->
      @states = {} if !@states?
      if !@states[state]?
        @states[state] = false
      if @states[state] != false
        @states[state] = false
        if @_notStates && @_notStates[state]?.length
          callback() for callback in @_notStates[state]
      return
  }
])


# --- Config ---
.factory('Backbone', ['$http', 'ServiceStates', ($http, ServiceStates) ->

  _.assign(Backbone.Collection.prototype, ServiceStates)

  Backbone.sync = (method, model, options) ->
    url = if typeof model.url == "function" then model.url() else model.url
    switch method
      when 'create'
        request = $http.post   url, model
      when 'read'
        request = $http.get    url
      when 'update'
        request = $http.put    url, model
      when 'delete'
        request = $http.delete url
    request.success(options.success).error(options.error)


  return Backbone
])
