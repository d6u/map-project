app = angular.module 'angular-easy-modal', []


# jq-easy-modal
app.directive 'jqEasyModal', ['$templateCache', '$compile', '$rootScope',
($templateCache, $compile, $rootScope) ->

  scope: true
  link: (scope, element, attrs) ->

    # init
    easyModalOptions = {
      top: 100
      onClose: ->
        element.empty().append $('<div>').addClass('jq-eady-modal-inner')
        $rootScope.$broadcast 'jqEasyModal_closed'
    }

    element.easyModal easyModalOptions


    # events
    scope.$on 'pop_jqEasyModal', (event, data) ->
      scope.data = data
      switch data.type
        when 'friends_panel'
          element.children('.jq-eady-modal-inner').attr('mp-friends-panel', '')
          element.html $compile(element.html())(scope)
      element.trigger 'openModal'

    scope.$on 'close_jqEasyModal', (event, data) ->
      element.trigger 'closeModal'
]
