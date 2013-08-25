# Little jQuery plugin to get cursor position of an input
# ----------------------------------------
(($) ->
  $.fn.getCursorPosition = ->
    input = this.get(0)
    if !input then return # // No (input) element found
    if 'selectionStart' in input
      # // Standard-compliant browsers
      return input.selectionStart
    else if document.selection
      # // IE
      input.focus()
      sel = document.selection.createRange()
      selLen = document.selection.createRange().text.length
      sel.moveStart('character', -input.value.length)
      return sel.text.length - selLen
)(jQuery)


###
attrs:
  miniTypeahead="options": options object contains options to customization
  miniTypeaheadList="list": list is a array contains dropdonw/up menu options
###
angular.module('mini-typeahead', [])

# ----------------------------------------
.directive('miniTypeahead',
['$compile',
( $compile)->

  priority: -1
  controller: ['$scope', '$attrs', ($scope, $attrs) ->

    # Default options
    @options = {
      watches: []
      watchResize: true

      # when true, mini-typeahead will adjust the postion of dropdown/up menu on
      # every $digest cycle
      watchPosition: true

      # provide a selector to select the container for dropdown/up menu to append
      # by default, menu will append to the parent of current element
      appendTo: null

      listClass: ''
      itemClass: ''
      cursorOnClass: ''
    }

    return
  ]
  link: (scope, element, attrs, MiniTypeaheadCtrl) ->

    # Read options and merge with defaults
    customeOptions = scope.$eval(attrs.miniTypeahead)
    MiniTypeaheadCtrl.options = angular.extend(MiniTypeaheadCtrl.options, customeOptions)

    # Create new scope for mini-typeahead-dropmenu
    menuScope = scope.$new()
    menuScope.MiniTypeaheadCtrl = MiniTypeaheadCtrl
    menuScope.inputElement = element

    # Create mini-typeahead-dropmenu DOM
    template = '<ol class="'+MiniTypeaheadCtrl.options.listClass+'" mini-typeahead-dropmenu ng-show="MiniTypeaheadCtrl.list.length"><li class="'+MiniTypeaheadCtrl.options.itemClass+'" ng-repeat="item in MiniTypeaheadCtrl.list">{{item.description}}</li></ol>'

    if !MiniTypeaheadCtrl.options.appendTo
      element.parent().append $compile(template)(menuScope)
    else
      $(MiniTypeaheadCtrl.options.appendTo).append $compile(template)(menuScope)

    # Update list content when new one available
    scope.$watch attrs.miniTypeaheadList, (newVal, oldVal) ->
      MiniTypeaheadCtrl.list = newVal
])


# mini-typeahead-dropmenu
# ----------------------------------------
.directive('miniTypeaheadDropmenu', ['$timeout', ($timeout) ->
  (scope, element, attrs) ->

    dropup = true
    cursorOnClass = scope.MiniTypeaheadCtrl.options.cursorOnClass

    # Give some default style to element
    element.css({
      position: 'absolute'
    })

    # Adjust menu position and dimension based on inputElement
    scope.$watch (() ->
      element.css({
        left: scope.inputElement.position().left
        width: scope.inputElement.outerWidth()
      })
      setTimeout (->
        distanceToBottom = $(window).height() - scope.inputElement.offset().top - scope.inputElement.outerHeight()
        distanceToTop    = scope.inputElement.offset().top
        menuHeight       = element.outerHeight()
        if distanceToTop > menuHeight && distanceToBottom < menuHeight
          # drop up
          element.css({
            top: 'auto'
            bottom: scope.inputElement.outerHeight()
          })
          dropup = true
        else
          # drop down
          element.css({
            top: scope.inputElement.outerHeight()
            bottom: 'auto'
          })
          dropup = false
      ), 200
      return
    ), ->


    # key codes:
    #   9:  tab
    #   27: escape
    #   down arrow: 40
    #   up arrow:   38
    scope.inputElement.on 'keydown', (event) ->
      # Enable drop down list selection through keyboard
      if (event.keyCode == 40 || event.keyCode == 38) && scope.inputElement.val().length
        if element.children().length
          downArrow = event.keyCode == 40
          upArrow   = event.keyCode == 38
          cursor    = element.children('.'+cursorOnClass).first()

          if downArrow
            if cursor.length
              cursor.removeClass(cursorOnClass)
              if cursor.next().length
                cursor.next().addClass(cursorOnClass)
              else
                element.children().first().addClass(cursorOnClass)
            else
              element.children().first().addClass(cursorOnClass)
          else if upArrow
            if cursor.length
              cursor.removeClass(cursorOnClass)
              if cursor.prev().length
                cursor.prev().addClass(cursorOnClass)
              else
                element.children().last().addClass(cursorOnClass)
            else
              element.children().last().addClass(cursorOnClass)

          # put selection text into input box
          scope.inputElement.val element.children('.'+cursorOnClass).html()
          return false

      # Enable tab select first one
      if event.keyCode == 9 && element.children().length
        scope.inputElement.val element.children().first().html()
        return false

      # Enable escape to close menu
      if event.keyCode == 27 && element.children().length
        scope.$apply -> scope.MiniTypeaheadCtrl.list = []
        return false


    # Click on items to search and show results on map
    element.on 'click', 'li', (event) ->
      scope.inputElement.val $(this).html()
      scope.$emit 'typeaheadListItemClicked'
])
