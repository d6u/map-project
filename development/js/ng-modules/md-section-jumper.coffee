angular.module('md-section-jumper', [])

# mdSectionJumper:       selector of scrolling element
# mdSectionJumperTarget: selector of target element to scroll into viewport
.directive 'mdSectionJumper', [->
  (scope, element, attrs) ->
    element.on 'click', ->
      scrollTop = $(attrs.mdSectionJumperTarget).offset().top
      $(attrs.mdSectionJumper).animate({scrollTop: scrollTop}, 200)
]
