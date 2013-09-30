angular.module('md-collapse', ['ngAnimate'])

# --- collapse ---
.directive('mdCollapse', [->
  controllerAs: 'MdCollapseCtrl'
  controller: [class MdCollapseCtrl
    constructor: ->
      @activeChild = 0
  ]
  link: (scope, element, attrs) ->
])

# --- slide down/up ---
.animation '.md-collapse-body-js', ->
  return {
    enter: (element, done) ->
      element.css({display: 'none'})
      element.slideDown 100, done
      return ->
        element.stop()
    leave: (element, done) ->
      element.slideUp 100, done
      return ->
        element.stop()
  }

