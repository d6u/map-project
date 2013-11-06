app.factory '$afterLoaded', [->
  return (callback) ->
    if @$serviceLoaded
      callback()
    else
      @once('service:ready', callback)
]
