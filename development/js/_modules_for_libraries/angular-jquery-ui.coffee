angular.module('angular-jquery-ui', [])
.directive 'jqueryUiSortable', [ ->
  (scope, element, attrs) ->

    # event funcions
    updateFn = (event, ui) ->
      match = /(.+) in (.+)/.exec attrs.jqueryUiSortable
      child = match[1]
      parent = match[2]

      parentArray = scope.$eval parent

      scope.$apply ->
        array = []
        element.children('[ng-repeat]').each (index) ->
          childScope = $(this).scope()
          childObj = childScope[child]
          array.push childObj
        parentArray.splice(0, parentArray.length)
        parentArray.push childObj for childObj in array

    # init
    sortableOptions =
      appendTo: document.body
      helper:   'clone'
      cursor:   'move'
      distance: 5
      handle:   '.mp-place-marker-icon'
      update:   updateFn
    element.sortable(sortableOptions)
]
