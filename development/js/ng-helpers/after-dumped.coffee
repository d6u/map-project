app.factory '$afterDumped', [->
  return (callback) ->
    if !@$serviceLoaded
      callback()
    else
      @once('service:reset', callback)
]
