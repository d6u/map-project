app.directive 'mpTabs', [->

  scope: true
  link: (scope, element, attrs) ->

    scope.tabs = []
    scope.tabs[0] =
      show: true
    scope.tabs[1] =
      show: false

    element.find('.mp-side-tabs a').each (index) ->
      $(this).on 'click', ->
        $(this).parent().addClass('mp-side-tab-active').siblings().removeClass('mp-side-tab-active')
        scope.$apply ->
          _.each scope.tabs, (tab) ->
            tab.show = false
          scope.tabs[index].show = true
]