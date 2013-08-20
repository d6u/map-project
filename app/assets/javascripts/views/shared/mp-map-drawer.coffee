app.directive 'mpMapDrawer', ['$rootScope', '$timeout',
($rootScope, $timeout) ->

  templateUrl: '/scripts/views/shared/md-drawer.html'
  scope: true
  controller: ['$scope', '$element', ($scope, $element) ->

    # Interface
    @maxmize = false
    @showDrawer = false
    @toggleDrawerButtonText = 'Show drawer'

    # Actions
    @getProjectTitle = ->
      if $scope.TheProject.project
        return $scope.TheProject.project.title
      else
        return $scope.TheProject.places.length + ' marked places'

    @toggleDrawer = ->
      $element.toggleClass 'md-drawer-show'
      $element.find('.cp-typeahead').toggleClass 'cp-typeahead-dropup'
      $timeout (-> google.maps.event.trigger($scope.TheMap.map, 'resize')), 200
      @showDrawer = !@showDrawer
      @toggleDrawerButtonText = if @showDrawer then 'Hide drawer' else 'Show drawer'

    @toggleDrawerSize = ->
      @maxmize = !@maxmize

  ]
  link: (scope, element, attrs, drawerCtrl) ->

    # Bind controller to scope
    scope.drawerCtrl = drawerCtrl

    # Interface
    scope.interface.centerSearchBar = true
    # element.find('.md-homepage-centered').removeClass 'md-homepage-centered'

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