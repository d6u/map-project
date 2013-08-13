# mp-user-section
# --------------------------------------------
app.directive 'mpUserSection', ['$rootScope', '$compile', '$templateCache',
'MpProjects', '$location', '$timeout', 'Restangular', 'MpChatbox',
($rootScope, $compile, $templateCache, MpProjects, $location, $timeout,
 Restangular, MpChatbox) ->

  getTemplate = ->
    if $rootScope.User.checkLogin()
      return $templateCache.get 'mp_user_section_tempalte_login'
    else
      return $templateCache.get 'mp_user_section_tempalte_logout'

  # return
  scope: true
  link: (scope, element, attrs) ->

    scope.fbLogin = ->
      $rootScope.User.login ->
        return if MpProjects.currentProject.places.length > 0 then '/new_project' else '/all_projects'

    scope.logout = ->
      $rootScope.User.logout()

    scope.showEmailLogin = ->
      template = $templateCache.get 'mp_user_section_tempalte_loginform'
      element.html $compile(template)(scope)

    scope.showEmailRegister = ->
      template = $templateCache.get 'mp_user_section_tempalte_logout'
      element.html $compile(template)(scope)

    scope.showFriendsPanel = ->
      $rootScope.$broadcast 'pop_jqEasyModal', {type: 'friends_panel'}


    scope.$on '$routeChangeSuccess', (event, current) ->
      if current.$$route.controller != 'OutsideViewCtrl'
        scope.interface.showUserSection = false
      else
        scope.interface.showUserSection = true
      element.html $compile(getTemplate())(scope)
]
