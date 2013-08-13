# mp-user-section
# --------------------------------------------
app.directive 'mpUserSection', ['$rootScope', '$compile', 'MpProjects',
'$location', '$timeout', 'Restangular', 'MpChatbox', 'mpTemplateCache',
($rootScope, $compile, MpProjects, $location, $timeout,
 Restangular, MpChatbox, mpTemplateCache) ->

  currentTemplate = ->
    return if $rootScope.User.checkLogin() then '/scripts/keepers/mp-user-section-after-login.html' else '/scripts/keepers/mp-user-section-before-login.html'

  # return
  scope: true
  link: (scope, element, attrs) ->

    scope.fbLogin = ->
      $rootScope.User.login ->
        return if MpProjects.currentProject.places.length > 0 then '/new_project' else '/all_projects'

    scope.logout = ->
      $rootScope.User.logout()

    scope.showEmailLogin = ->
      mpTemplateCache.get('/scripts/keepers/mp-user-section-login-form.html').then (template) ->
        element.html $compile(template)(scope)

    scope.showEmailRegister = ->
      mpTemplateCache.get('/scripts/keepers/mp-user-section-before-login.html').then (template) ->
        element.html $compile(template)(scope)

    scope.showFriendsPanel = ->
      $rootScope.$broadcast 'pop_jqEasyModal', {type: 'friends_panel'}

    # events
    # ----------------------------------------
    scope.$on '$routeChangeSuccess', (event, current) ->
      mpTemplateCache.get(currentTemplate()).then (template) ->
        element.html $compile(template)(scope)
      scope.interface.showUserSection = false
      # scope.interface.showUserSection = (current.$$route.controller == 'OutsideViewCtrl')
]
