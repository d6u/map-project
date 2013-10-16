app.factory 'MpUserGuide',
['$templateCache','mpTemplateCache','$compile','$rootScope','$timeout',
( $templateCache,  mpTemplateCache,  $compile,  $rootScope,  $timeout) ->

  # --- Guide ---
  guideContent = [
    {
      selector:  '#user-guide-search'
      title:     'Search Bar'
      message:   'User this search bar to find the first place you want to go.'
      placement: 'top'
    },
    {
      selector:  '#user-guide-results'
      title:     'Search Results'
      message:   'Click to open a list of search results.'
      placement: 'top'
    },
    {
      selector:  '#user-guide-directions'
      title:     'Direction'
      message:   'Show directions between places you save (when you have more than one place saved).'
      placement: 'right'
    }
  ]


  # --- Init ---
  popoverScope = $rootScope.$new()

  popoverScope.next = ->
    MpUserGuide.nextStep()

  popoverScope.skip = ->
    MpUserGuide.lastPopover.popover('destroy')
    MpUserGuide.stepCounter = guideContent.length - 1


  # --- Guide Control Service ---
  MpUserGuide = {

    scope: popoverScope

    stepCounter: 0
    lastPopover: null

    init: ->
      @stepCounter = 0
      @$renderGuide(@stepCounter)

    nextStep: ->
      if guideContent[@stepCounter + 1]?
        @stepCounter++
        @$renderGuide(@stepCounter)
      else
        @lastPopover.popover('destroy')


    # --- helpers ---
    $renderGuide: (stepIndex) ->
      mpTemplateCache.get('/scripts/ng-components/user-guide/user-guide-step.html')
      .then (template) =>
        @lastPopover?.popover('destroy')
        step           = guideContent[stepIndex]
        @scope.isLast  = if guideContent[stepIndex + 1]? then false else true
        @scope.message = step.message
        content        = $compile(template)(@scope)
        @lastPopover   = @$renderPopover(step.selector, step.placement, step.title, content)


    $renderPopover: (selector, placement, title, content) ->
      popoverTarget = $(selector).popover({
        html:      true
        container: 'body'
        trigger:   'manual'
        placement: placement
        title:     title
        content:   content
      })

      # add timeout to properly position popover
      setTimeout ->
        popoverTarget.popover('show')

        popoverClickCallback = ->
          popoverScope.next()

        popoverTarget.one 'click', popoverClickCallback

        popoverTarget.one 'hide.bs.popover', ->
          popoverTarget.off 'click', popoverClickCallback

      return popoverTarget
  }
  # END MpUserGuide


  return MpUserGuide
]
