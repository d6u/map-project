app = angular.module 'angular-mp.home.toolbar', []


# mp-control-toolbar
app.directive 'mpControlToolbar', [->
  templateUrl: 'mp_control_toolbar_template'
  link: (scope, element, attrs) ->


]


# mp-inputbox
# ========================================
app.directive 'mpInputbox', ['$location', ($location) ->
  (scope, element, attrs) ->

    scope.clearInput = (control) ->
      control.input = ''
]


# search box
app.directive 'searchBox', [->
  (scope, element, attrs) ->

    if scope.inMapview
      scope.googleMap.searchBox = new google.maps.places.SearchBox(element[0])
      scope.googleMap.searchBoxReady.resolve()
]


# mp-user-section
app.directive 'mpUserSection', [->
  templateUrl: 'mp_user_section_tempalte_logout'
  link: (scope, element, attrs) ->


]


# mp-places-list
app.directive 'mpPlacesList', ['$window', ($window) ->

  templateUrl: 'mp_places_search_results_template'
  link: (scope, element, attrs) ->

    $($window).on 'resize', ->
      element.css {maxHeight: $($window).height() - 112 - 20}
    $($window).trigger 'resize'

    element.perfectScrollbar({
      wheelSpeed: 20
      wheelPropagation: true
      })

    scope.$watch 'currentProject.places.length', (newVal, oldVal) ->
      # TODO: scroll to places list last (newest) item
      element.scrollTop 0
      element.perfectScrollbar 'update'

    scope.$watch 'googleMap.searchResults.length', (newVal, oldVal) ->
      # TODO: scroll to search result position
      element.scrollTop 0
      element.perfectScrollbar 'update'
]
