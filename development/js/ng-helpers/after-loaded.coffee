app.factory '$afterLoaded', [->
  return (callback) ->
    @on('service:ready', callback)
    callback() if @$serviceLoaded
]
