# require Backbone.js


angular.module('ngBackbone', [])

# --- States Management ---
.factory('ServiceStates', [->
  return {
    _checkState: (name, value) ->
      @states       ?= {}
      @states[name] ?= false
      return if @states[name] == value then true else false


    _addStateCallback: (state, callback, whileNot) ->
      if whileNot
        @_notStates        ?= {}
        @_notStates[state] ?= []
        @_notStates[state].push(callback)
      else
        @_states        ?= {}
        @_states[state] ?= []
        @_states[state].push(callback)
      return


    _addOnceStateCallback: (state, callback, whileNot) ->
      if whileNot
        @_notOnceStates        ?= {}
        @_notOnceStates[state] ?= []
        @_notOnceStates[state].push(callback)
      else
        @_onceStates        ?= {}
        @_onceStates[state] ?= []
        @_onceStates[state].push(callback)
      return


    _triggerStateCallbacks: (state, whileNot) ->
      if whileNot
        i = @_notStates?[state]?.length
        while i--
          @_notStates[state][i]()
        j = @_notOnceStates?[state]?.length
        while j--
          @_notOnceStates[state].pop()()
      else
        i = @_states?[state]?.length
        while i--
          @_states[state][i]()
        j = @_onceStates?[state]?.length
        while j--
          @_onceStates[state].pop()()
      return


    while: (state, callback) ->
      callback() if @_checkState(state, true)
      @_addStateCallback(state, callback)
      return


    onceWhile: (state, callback) ->
      if @_checkState(state, true)
        callback()
      else
        @_addOnceStateCallback(state, callback)
      return


    whileNot: (state, callback) ->
      callback() if @_checkState(state, false)
      @_addStateCallback(state, callback, true)
      return


    onceWhileNot: (state, callback) ->
      if @_checkState(state, false)
        callback()
      else
        @_addOnceStateCallback(state, callback, true)
      return


    enter: (state) ->
      if @_checkState(state, false)
        @states[state] = true
        @_triggerStateCallbacks(state)
      return


    leave: (state) ->
      if @_checkState(state, true)
        @states[state] = false
        @_triggerStateCallbacks(state, true)
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
