app.directive 'mdDrawer',
['$rootScope', '$timeout', '$routeSegment',
( $rootScope,   $timeout,   $routeSegment) ->

  templateUrl: '/scripts/components/map/md-drawer.html'
  controllerAs: 'drawerCtrl'
  controller: ['$scope', '$element', ($scope, $element) ->

    # Interface
    @maxmize = false
    @showDrawer = false
    @toggleDrawerButtonText = 'Show drawer'
    @showEditProjectSubsection = false

    # Actions
    @getProjectTitle = ->
      if $scope.TheProject
        if $scope.TheProject.project
          return $scope.TheProject.project.title
        else
          return $scope.TheProject.places.length + ' marked places'
      else
        return

    @toggleDrawer = ->
      $element.toggleClass 'md-drawer-show'
      $element.find('.cp-typeahead').toggleClass 'cp-typeahead-dropup'
      $timeout (-> google.maps.event.trigger($scope.mapCtrl.googleMap, 'resize')), 200
      @showDrawer = !@showDrawer
      @toggleDrawerButtonText = if @showDrawer then 'Hide drawer' else 'Show drawer'

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

    # Interface
    if $routeSegment.name == 'ot'
      scope.interface.centerSearchBar = true
    else
      scope.interface.centerSearchBar = false
      element.find('.md-homepage-centered').removeClass 'md-homepage-centered'

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
