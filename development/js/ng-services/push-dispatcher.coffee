app.factory 'PushDispatcher', ['Backbone', 'socket', (Backbone, socket) ->

  class PushDispatcher
    constructor: ->
      socket.on 'chatData', (data) =>
        eventName = switch data.item_type
          when 0 then 'chatMessage'
          when 1 then 'placeAdded'
          when 2 then 'placeRemoved'
        @trigger(eventName, data)


  _.assign(PushDispatcher.prototype, Backbone.Events)

  return new PushDispatcher
]
