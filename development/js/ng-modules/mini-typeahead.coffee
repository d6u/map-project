# Little jQuery plugin to get cursor position of an input
# ----------------------------------------
(($) ->
  $.fn.getCursorPosition = ->
    el  = this.get(0)
    pos = 0 # // default value if no (input) element found
    if el.selectionStart?
      # // Standard-compliant browsers
      pos = el.selectionStart
    else if document.selection?
      # // IE
      el.focus()
      Sel = document.selection.createRange()
      SelLength = document.selection.createRange().text.length
      Sel.moveStart('character', -el.value.length)
      pos = Sel.text.length - SelLength
    return pos
)(jQuery)


# --- Module ---
angular.module('mini-typeahead', [])

# ----------------------------------------
.directive('miniTypeahead', ['$compile', ($compile) ->

  priority: -1
  controller: ['$scope', '$attrs', class MiniTypeaheadCtrl
    constructor: ($scope, $attrs) ->

      @options = _.assign {
        # default options
        watches: []
        watchResize: true

        # when true, mini-typeahead will adjust the postion of dropdown/up menu on
        # every $digest cycle
        watchPosition: true

        # provide a selector to select the container for dropdown/up menu to append
        # by default, menu will append to the parent of current element
        appendTo: undefined

        listClass: 'mini-typeahead-list'
        itemClass: 'mini-typeahead-item'
        cursorOnClass: 'mini-typeahead-cursor-on'
      }, $scope.$eval($attrs.miniTypeahead)


      # UI
      @showMenu = true


      # attach change and select method to self
      @change = (input, offset) ->
        $scope.$apply ->
          $scope.$eval($attrs.miniTypeaheadChange)(input, offset)

      @select = (input, offset) ->
        $scope.$apply ->
          $scope.$eval($attrs.miniTypeaheadSelect)(input, offset)
  ]
  link: (scope, element, attrs, MiniTypeaheadCtrl) ->

    # Create new scope for mini-typeahead-dropmenu
    menuScope                   = scope.$new()
    menuScope.MiniTypeaheadCtrl = MiniTypeaheadCtrl
    menuScope.inputElement      = element

    # Create mini-typeahead-dropmenu DOM
    template = "<ol class=\"#{MiniTypeaheadCtrl.options.listClass}\" mini-typeahead-dropmenu ng-show=\"#{attrs.miniTypeaheadList}.length && MiniTypeaheadCtrl.showMenu\"><li class=\"#{MiniTypeaheadCtrl.options.itemClass}\" ng-repeat=\"item in #{attrs.miniTypeaheadList}\">{{item.description}}</li></ol>"

    if !MiniTypeaheadCtrl.options.appendTo?
      element.parent().append $compile(template)(menuScope)
    else
      $(MiniTypeaheadCtrl.options.appendTo).append $compile(template)(menuScope)


    # --- Events ---
    # key codes:
    #   9:  tab
    #   13: enter
    #   27: escape
    #   37: left  arrow
    #   38: up    arrow
    #   39: right arrow
    #   40: down  arrow
    element.on 'keyup', (event) ->
      # call change
      if !(event.keyCode in [13, 27, 38, 40])
        MiniTypeaheadCtrl.showMenu = true
        MiniTypeaheadCtrl.change(element.val(), element.getCursorPosition())

      # Call select method if pressed enter
      if event.keyCode == 13
        MiniTypeaheadCtrl.select(element.val(), element.getCursorPosition())

      return
])


# mini-typeahead-dropmenu
# ----------------------------------------
.directive('miniTypeaheadDropmenu', ['$timeout', ($timeout) ->
  (scope, element, attrs) ->

    dropup = true
    cursorOnClass = scope.MiniTypeaheadCtrl.options.cursorOnClass


    # --- Callbacks ---
    adjustMenuPosition = ->
      element.css({
        left:  scope.inputElement.position().left
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


    # --- Initialize ---
    # Give some default style to element
    element.css({position: 'absolute'})

    # Adjust position when property in watches option changed
    for watchParam in scope.MiniTypeaheadCtrl.options.watches
      scope.$watch watchParam, adjustMenuPosition

    # Adjust menu position and dimension based on inputElement
    if scope.MiniTypeaheadCtrl.options.watchPosition
      scope.$watch adjustMenuPosition, ->


    # key codes:
    #   9:  tab
    #   13: enter
    #   27: escape
    #   37: left  arrow
    #   38: up    arrow
    #   39: right arrow
    #   40: down  arrow
    scope.inputElement.on 'keydown', (event) ->
      # Enable drop down list selection through keyboard
      if (event.keyCode == 40 || event.keyCode == 38) && scope.inputElement.val().length && element.children().length
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
      if event.keyCode == 9
        if element.children().length && !element.children('.'+cursorOnClass).length
          scope.inputElement.val element.children().first().html()
        return false

      # Enable escape to close menu
      if event.keyCode == 27 && element.children().length
        scope.$apply -> scope.MiniTypeaheadCtrl.showMenu = false
        return false


    # Click on items to search and show results on map
    element.on 'click', 'li', (event) ->
      scope.inputElement.val $(this).html()
      scope.MiniTypeaheadCtrl.select(scope.inputElement.val(), scope.inputElement.getCursorPosition())
])
