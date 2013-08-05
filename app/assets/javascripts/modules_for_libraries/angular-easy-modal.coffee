app = angular.module 'angular-easy-modal', []

# easy modal
app.directive 'easyModal', [ ->
  (scope, element, attrs) ->

    # callbacks
    scope.close = ->
      element.trigger 'closeModal'

    # init
    easyModalOptions = {}

    element.easyModal easyModalOptions

    # events
    scope.$on attrs.easyModal, -> element.trigger 'openModal'
]
