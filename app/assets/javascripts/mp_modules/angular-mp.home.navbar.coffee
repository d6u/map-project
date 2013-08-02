app = angular.module 'angular-mp.home.navbar', []


# dropdonw menu
app.directive 'navbarDropdownMenu',
['$rootScope', 'FB', '$compile', '$templateCache', '$q',
($rootScope, FB, $compile, $templateCache, $q) ->

  # return
  templateUrl: 'navbar_dropdown_menu'
  link: (scope, element, attrs) ->

    scope.$watch 'user.fb_access_token', (newValue, oldValue, scope) ->
      templateName = if newValue then 'navbar_dropdown_menu_logged' else 'navbar_dropdown_menu'
      template = $templateCache.get templateName
      element.html(template)
      $compile(element.contents())(scope)

]


# search box
app.directive 'searchBox', ['$location',
($location) ->
  (scope, element, attrs) ->
    scope.googleMap.searchBox = new google.maps.places.SearchBox(element[0])

    scope.clearSearchResults = ->
      element.val('')
      marker.setMap(null) for marker in scope.googleMap.markers
      scope.googleMap.markers = []
]
