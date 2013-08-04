app = angular.module 'angular-jquery-ui', []


app.directive 'jqueryUiSortable', [ ->
  (scope, element, attrs) ->

    # event funcions
    updateFn = (event, ui) ->
      match = /(.+) in (.+)/.exec attrs.jqueryUiSortable
      child = match[1]
      parent = match[2]

      scope.$apply ->
        array = []
        element.children('[ng-repeat]').each (index) ->
          childScope = $(this).scope()
          childObj = childScope.$eval child
          array.push childObj
        scope.$eval parent + '= []'
        parentArray = scope.$eval parent
        parentArray.push childObj for childObj in array
        scope.$emit 'placeListSorted'

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
