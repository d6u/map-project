# mp-user-section
# --------------------------------------------
app.directive 'mpUserSection',
['$location', 'Restangular', 'mpTemplateCache', '$route', '$compile',
( $location,   Restangular,   mpTemplateCache,   $route,   $compile) ->

  currentTemplate = ->
    if $route.current.$$route.controller == 'OutsideViewCtrl'
      return '/scripts/keepers/mp-user-section-before-login.html'
    else return '/scripts/keepers/mp-user-section-after-login.html'

  # return
  scope: true
  controller: ['$scope', '$element', 'mpTemplateCache', '$compile',
    ($scope, $element, mpTemplateCache, $compile) ->

      @fbLogin = ->
        $scope.MpUser.login ->
          if $scope.TheProject.places.length > 0
            return $scope.MpProjects.createProject().then (project) ->
              $places = project.all('places')
              $scope.MpProjects.TheProject = $scope.TheProject
              return '/home/project/'+project.id
          else return '/home'

      @logout = ->
        $scope.MpUser.logout()

      @showEmailLogin = ->
        mpTemplateCache.get('/scripts/keepers/mp-user-section-login-form.html').then (template) ->
          $element.html $compile(template)($scope)

      @showEmailRegister = ->
        mpTemplateCache.get('/scripts/keepers/mp-user-section-before-login.html').then (template) ->
          $element.html $compile(template)($scope)
  ]
  link: (scope, element, attrs, mpUserSectionCtrl) ->

    scope.mpUserSection = mpUserSectionCtrl

    mpTemplateCache.get(currentTemplate()).then (template) ->
      element.html $compile(template)(scope)
    scope.interface.showUserSection = false

    # init
    scope.searchFriends = {}

    # events
    # ----------------------------------------
    scope.$watch 'searchFriends.input', (newVal, oldVal) ->
      if newVal && newVal.length > 0
        $users = Restangular.all 'users'
        $users.getList({name: newVal}).then (users) ->
          scope.searchFriends.results = users
]
