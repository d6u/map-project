app.factory 'ServiceStates',
[->
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
]
