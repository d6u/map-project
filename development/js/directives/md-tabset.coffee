###
DOM Structures:

  md-tabset
    md-tabs
    md-pages
###

angular.module('md-tabset', [])
.directive('mdTabset', [->
  (scope, element, attrs) ->

    # TODO: add more customization
])
.directive('mdTabs', [->
  (scope, element, attrs) ->

    element.children().on('click', (event) ->
      idx = $(this).index()
      element.siblings('[md-pages]').children().eq(idx).css({
        opacity: 1
        visibility: 'visible'
      }).siblings().css({
        opacity: 0
        visibility: 'hidden'
      })
    )
])
.directive('mdPages', [->
  (scope, element, attrs) ->

    element.children().first().css({
      opacity: 1
      visibility: 'visible'
    })
    .siblings().css({
      opacity: 0
      visibility: 'hidden'
    })
])
