# mp-bottom-modalbox
# ----------------------------------------
# type: editProject: mp-edit-project-modal
#
app.directive 'mpBottomModalbox', ['$templateCache', '$compile', '$timeout',
($templateCache, $compile, $timeout) ->

  scope: true
  link: (scope, element, attrs) ->

    scope.closeModal = ->
      element.removeClass 'mp-bottom-modalbox-show'
      $timeout (->
        element.find('.mp-bottom-modalbox-container').removeAttr(scope.removingAttr).html('').scope().$destroy()
      ), 200

    scope.$on 'showBottomModalbox', (event, data) ->
      switch data.type
        when 'editProject'
          scope.project = data.project
          scope.removingAttr = 'mp-edit-project-modal'
          element.find('.mp-bottom-modalbox-container').attr(scope.removingAttr, '')
          html = $compile(element.html())(scope)
          element.html html
      # fix no animation problem, becasue content are dynamically generated
      # make sure angular not add class until current scope life cycle complete
      $timeout (-> element.addClass 'mp-bottom-modalbox-show')
]
