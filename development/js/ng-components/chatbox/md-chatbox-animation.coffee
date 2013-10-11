app.animation '.md-chatbox-body', ->
  return {
    addClass: (element, className, done) ->
      if className == 'md-chatbox-body-show'
        historyContainer = element.find('.md-chatbox-b-histories-container')
        targetScrollTop  = 0 - historyContainer.height()
        historyContainer.children().each ->
          targetScrollTop += $(this).outerHeight(true)
        historyContainer.scrollTop(targetScrollTop)
      done()

      return
  }
