# mp-user-section-tabs
app.directive 'mpUserSectionTabs', [->

  link: (scope, element, attrs) ->

    scope.tabs = [true, false, false]

    scope.showTab = (index) ->
      element.children('div.btn-group').children('button').each (idx) ->
        if idx == index
          $(this).removeClass('btn-default').addClass('btn-primary')
        else
          $(this).removeClass('btn-primary').addClass('btn-default')
      for i in [0..2]
        scope.tabs[i] = false
      scope.tabs[index] = true
]
