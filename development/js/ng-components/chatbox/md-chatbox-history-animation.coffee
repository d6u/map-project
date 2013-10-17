app.animation '.md-chatbox-bh-item', ->
  return {
    enter: (element, done) ->
      done()
      setTimeout ->
        secondLastItem = element.prev()
        toBottom = element.parent().height() - secondLastItem.position().top - secondLastItem.outerHeight(true)
        if toBottom > -70
          targetScrollTop = 0 - element.parent().height()
          element.parent().children().each ->
            targetScrollTop += $(this).outerHeight(true)
          element.parent().animate({scrollTop: targetScrollTop}, 200, 'easeOutCubic')

      return
  }
