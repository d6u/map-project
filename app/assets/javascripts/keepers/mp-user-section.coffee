# mp-user-section
# --------------------------------------------
app.directive 'mpUserSection', ['$rootScope', '$compile', 'MpProjects',
'$location', '$timeout', 'Restangular', 'MpChatbox', 'mpTemplateCache',
'$routeSegment',
($rootScope, $compile, MpProjects, $location, $timeout, Restangular, MpChatbox,
 mpTemplateCache, $routeSegment) ->

  currentTemplate = ->
    if $routeSegment.startsWith('ot')
      return '/scripts/keepers/mp-user-section-before-login.html'
    else return '/scripts/keepers/mp-user-section-after-login.html'

  # return
  scope: true
  templateUrl: '/scripts/keepers/mp-user-section-before-login.html'
  link: (scope, element, attrs) ->

    mpTemplateCache.get(currentTemplate()).then (template) ->
      element.html $compile(template)(scope)
    scope.interface.showUserSection = false

    scope.fbLogin = ->
      $rootScope.MpUser.login ->
        return if MpProjects.currentProjectPlaces.length > 0 then '/new_project' else '/all_projects'

    scope.logout = ->
      $rootScope.MpUser.logout()

    scope.showEmailLogin = ->
      mpTemplateCache.get('/scripts/keepers/mp-user-section-login-form.html').then (template) ->
        element.html $compile(template)(scope)

    scope.showEmailRegister = ->
      mpTemplateCache.get('/scripts/keepers/mp-user-section-before-login.html').then (template) ->
        element.html $compile(template)(scope)


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
