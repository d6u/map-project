# Toolbar Inputs
# ----------------------------------------
# mp-inputbox
app.directive 'mpInputbox', ['$location', '$rootScope',
($location, $rootScope) ->
  (scope, element, attrs) ->

    scope.clearInput = (control) ->
      control.input = ''
      element.find('input').val('')
      $rootScope.$broadcast 'mpInputboxClearInput'
]
