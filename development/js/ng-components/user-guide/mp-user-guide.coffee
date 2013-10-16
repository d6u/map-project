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
      message:   'You can open a list of search results. Click the check mark save the place. (You place will not be transfer to the cloud if you do not login.)'
      placement: 'top'
    }
  ]


  # --- Init ---
  popoverScope = $rootScope.$new()

  popoverScope.next = ->
    MpUserGuide.nextStep()

  popoverScope.skip = ->
    MpUserGuide.lastPopover.popover('destroy')
    MpUserGuide.stepCounter = guideContent.length - 1

  popoverScope.close = ->
    MpUserGuide.lastPopover.popover('destroy')
    MpUserGuide.stepCounter--


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

      return popoverTarget
  }
  # END MpUserGuide


  return MpUserGuide
]
