angular.module('md-collapse', [])

# --- collapse ---
.directive('mdCollapse', [->
  controller: [class MdCollapseCtrl
    constructor: ->
      @activeChild = 0
  ]
  link: (scope, element, attrs) ->

])

# --- children ---
.directive('mdCollapseChild', [->
  controller: [class MdCollapseChildCtrl
    constructor: ->
  ]
  require: ['^mdCollapse', 'mdCollapseChild']
  link: (scope, element, attrs, Ctrls) ->
    Ctrls[1].index = element.index()
    scope.$watch (->
      Ctrls[0].activeChild
    ), (newVal) ->
      if newVal != undefined
        Ctrls[1].showBody = (newVal == element.index())
])

# --- head of child ---
.directive('mdCollapseHead', [->
  require: ['^mdCollapse', '^mdCollapseChild']
  link: (scope, element, attrs, Ctrls) ->
    element.on 'click', ->
      scope.$apply ->
        Ctrls[0].activeChild = Ctrls[1].index
])

# --- body of child ---
.directive('mdCollapseBody', [->
  require: '^mdCollapseChild'
  link: (scope, element, attrs, MdCollapseChildCtrl) ->
    scope.$watch (->
      MdCollapseChildCtrl.showBody
    ), (newVal) ->
      if newVal != undefined
        if newVal then element.slideDown() else element.slideUp()
])
