app.directive 'mdSearchViewSearchinput',
[->
  (scope, element, attrs) ->

    element.on 'keypress', (event) ->
      if event.keyCode == 13
        scope.$apply ->
          scope.searchViewCtrl.searchUser()
]
