app.factory '$afterDumped', [->
  return (callback) ->
    @on('service:reset', callback)
    callback() if !@$serviceLoaded
]
