app.directive 'mdDrawer',
['$rootScope', '$timeout', '$routeSegment',
( $rootScope,   $timeout,   $routeSegment) ->

  templateUrl: '/scripts/components/drawer/md-drawer.html'
  controllerAs: 'drawerCtrl'
  controller: ['$scope', '$element', ($scope, $element) ->

    # Interface
    @toggleDrawerSize = ->
      @maxmize = !@maxmize

    @toggleEditProject = ->
      @showEditProjectSubsection = !@showEditProjectSubsection

    @displayAllMarkers = ->
      bounds = new google.maps.LatLngBounds()
      for place in $scope.mapCtrl.theProject.places
        bounds.extend place.$$marker.getPosition()
      $scope.mapCtrl.setMapBounds(bounds)

    @showPlaceOnMap = (place) ->
      $scope.mapCtrl.setMapCenter(place.$$marker.getPosition())
      google.maps.event.trigger(place.$$marker, 'click')

    return
  ]
  link: (scope, element, attrs, drawerCtrl) ->

    # Actions
    scope.clearInput = (control) ->
      scope.searchbox.input = ''
      element.find('input').val('')
      scope.TheMap.searchResults = []

    scope.fbLogin = ->
      # TODO
      # $rootScope.MpUser.login ->
      #   return if scope.MpProjects.currentProjectPlaces.length > 0 then '/new_project' else '/all_projects'

    scope.showProjectAddFriendsModal = ->
      $rootScope.$broadcast 'showProjectAddFriendsModal', {name: 'test'}
]
