app.directive 'mdDrawer',
['$rootScope', '$timeout', '$routeSegment',
( $rootScope,   $timeout,   $routeSegment) ->

  templateUrl: '/scripts/views/_map/md-drawer.html'
  scope: true
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
      $timeout (-> google.maps.event.trigger($scope.TheMap.map, 'resize')), 200
      @showDrawer = !@showDrawer
      @toggleDrawerButtonText = if @showDrawer then 'Hide drawer' else 'Show drawer'

    @toggleDrawerSize = ->
      @maxmize = !@maxmize

    @toggleEditProject = ->
      @showEditProjectSubsection = !@showEditProjectSubsection

  ]
  link: (scope, element, attrs, drawerCtrl) ->

    # Bind controller to scope
    scope.drawerCtrl = drawerCtrl

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