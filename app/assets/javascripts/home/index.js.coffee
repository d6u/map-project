#= require libraries/lodash.js
#= require libraries/socket.io.min.js
#= require libraries/jquery-ui-1.10.3.custom.min.js
#= require libraries/jquery.easyModal.js
#= require libraries/masonry.pkgd.min.js
#= require libraries/bootstrap.min.js
#= require libraries/perfect-scrollbar-0.4.3.min.js
#= require libraries/perfect-scrollbar-0.4.3.with-mousewheel.min.js

#= require libraries/angular.min.js
#= require libraries/restangular.js

#= require modules_for_libraries/angular-easy-modal.coffee
#= require modules_for_libraries/angular-socket.io.coffee
#= require modules_for_libraries/angular-masonry.coffee
#= require modules_for_libraries/angular-perfect-scrollbar.coffee
#= require modules_for_libraries/angular-bootstrap.coffee
#= require modules_for_libraries/angular-jquery-ui.coffee

#= require mp_modules/angular-mp.home.initializer.coffee
#= require mp_modules/angular-mp.api.coffee
#= require mp_modules/angular-mp.home.map.coffee
#= require mp_modules/angular-mp.home.toolbar.coffee
#= require mp_modules/angular-mp.home.outside-view.coffee
#= require mp_modules/angular-mp.home.all-projects-view.coffee
#= require mp_modules/angular-mp.home.new-project-view.coffee
#= require mp_modules/angular-mp.home.project-view.coffee
#= require mp_modules/angular-mp.home.chatbox.coffee



# declear
app = angular.module 'mapApp', [
  'restangular',

  'angular-easy-modal',
  'angular-socket.io',
  'angular-masonry',
  'angular-perfect-scrollbar',
  'angular-bootstrap',
  'angular-jquery-ui',

  'angular-mp.home.initializer',
  'angular-mp.api',
  'angular-mp.home.map',
  'angular-mp.home.toolbar',
  'angular-mp.home.outside-view',
  'angular-mp.home.all-projects-view',
  'angular-mp.home.new-project-view',
  'angular-mp.home.project-view',
  'angular-mp.home.chatbox'
]


# config
app.config([
  'socketProvider', '$httpProvider', '$routeProvider',
  '$locationProvider',
  (socketProvider, $httpProvider, $routeProvider,
   $locationProvider) ->

    # route
    $routeProvider
    .when('/', {
      controller: 'OutsideViewCtrl'
      templateUrl: 'outside_view'
      resolve:
        User: 'User'
    })
    .when('/all_projects', {
      controller: 'AllProjectsViewCtrl'
      templateUrl: 'all_projects_view'
      resolve:
        User: 'User'
        socket: 'socket'
    })
    .when('/new_project', {
      controller: 'NewProjectViewCtrl'
      templateUrl: 'new_project_view'
      resolve:
        User: 'User'
        socket: 'socket'
    })
    .when('/project/:project_id', {
      controller: 'ProjectViewCtrl'
      templateUrl: 'project_view'
      resolve:
        User: 'User'
        socket: 'socket'
    })
    .otherwise({redirectTo: '/'})

    $locationProvider.html5Mode true

    # CSRF
    token = angular.element('meta[name="csrf-token"]').attr('content')
    $httpProvider.defaults.headers.common['X-CSRF-Token'] = token

    # google map
    google.maps.visualRefresh = true

    # socket
    socketProvider.setServerUrl location.protocol + '//' + location.hostname + ':4000'
])


# run
app.run(['$rootScope', '$location', 'User', 'MpProjects', 'socket',
($rootScope, $location, User, MpProjects, socket) ->

  socket.then (socket) ->
    $rootScope.socket = socket

  User.then (User) ->
    $rootScope.User = User
    $rootScope.MpProjects = MpProjects
    # filter
    if $rootScope.User.fb_access_token()
      $location.path('/all_projects') if $location.path() == '/'
    else
      $location.path('/') if $location.path() != '/'

    $rootScope.$on '$routeChangeStart', (event, future, current) ->
      switch future.$$route.controller
        when 'OutsideViewCtrl'
          $location.path('/all_projects') if User.fb_access_token()
        when 'AllProjectsViewCtrl'
          $location.path('/') if !User.fb_access_token()
        when 'NewProjectViewCtrl'
          $location.path('/') if !User.fb_access_token()
        when 'ProjectViewCtrl'
          $location.path('/') if !User.fb_access_token()

  $rootScope.interface = {}

  # events
  $rootScope.$on '$routeChangeSuccess', (event, current) ->
    switch current.$$route.controller
      when 'OutsideViewCtrl'
        $rootScope.inMapview = true
      when 'AllProjectsViewCtrl'
        $rootScope.inMapview = false
      when 'NewProjectViewCtrl'
        $rootScope.inMapview = true
      when 'ProjectViewCtrl'
        $rootScope.inMapview = true
])


# mp-user-section
# --------------------------------------------
app.directive 'mpUserSection', ['$rootScope', '$compile', '$templateCache',
'MpProjects', '$location',
($rootScope, $compile, $templateCache, MpProjects, $location) ->

  getTemplate = ->
    if $rootScope.User.checkLogin()
      return $templateCache.get 'mp_user_section_tempalte_login'
    else
      return $templateCache.get 'mp_user_section_tempalte_logout'

  # callbacks
  loginSuccess = ->
    if MpProjects.currentProject.places.length > 0
      $location.path('/new_project')
    else
      $location.path('/all_projects')

  logoutSuccess = ->
    $location.path('/')

  # return
  link: (scope, element, attrs) ->

    scope.interface.showUserSection = false

    scope.fbLogin = ->
      $rootScope.User.login(loginSuccess, logoutSuccess)

    scope.logout = ->
      $rootScope.User.logout logoutSuccess

    scope.showEmailLogin = ->
      template = $templateCache.get 'mp_user_section_tempalte_loginform'
      html = $compile(template)(scope)
      element.html html

    scope.showEmailRegister = ->
      template = $templateCache.get 'mp_user_section_tempalte_logout'
      html = $compile(template)(scope)
      element.html html

    scope.$on '$routeChangeSuccess', (event, current) ->
      template = getTemplate()
      html = $compile(template)(scope)
      element.html html
]


# mp-headsup-messager
# ----------------------------------------
# type: (default: null), danger, success, info
app.directive 'mpHeadsupMessager', ['$rootScope', '$timeout',
($rootScope, $timeout) ->
  (scope, element, attrs) ->

    scope.message = {}
    timeoutHandle = null

    $rootScope.$on 'showHeadsupMessage', (event, message) ->
      element.removeClass 'mp-headsup-messager-show'
      $timeout.cancel timeoutHandle if timeoutHandle
      scope.message.type = if message.type then 'alert-' + message.type else null
      scope.message.title = message.title
      scope.message.content = message.content
      scope.$apply()
      element.addClass 'mp-headsup-messager-show'
      timeoutHandle = $timeout (-> element.removeClass 'mp-headsup-messager-show'), 5000

    element.find('#mp_headsup_messager_close_button').on 'click', ->
      element.removeClass 'mp-headsup-messager-show'
      $timeout.cancel timeoutHandle if timeoutHandle
]


# mp-bottom-modalbox
# ----------------------------------------
# type: editProject: mp-edit-project-modal
#
app.directive 'mpBottomModalbox', ['$templateCache', '$compile', '$timeout',
($templateCache, $compile, $timeout) ->

  scope: true
  link: (scope, element, attrs) ->

    scope.closeModal = ->
      element.removeClass 'mp-bottom-modalbox-show'
      $timeout (->
        element.find('.mp-bottom-modalbox-container').removeAttr(scope.removingAttr).html('').scope().$destroy()
      ), 200

    scope.$on 'showBottomModalbox', (event, data) ->
      switch data.type
        when 'editProject'
          scope.project = data.project
          scope.removingAttr = 'mp-edit-project-modal'
          element.find('.mp-bottom-modalbox-container').attr(scope.removingAttr, '')
          html = $compile(element.html())(scope)
          element.html html
      # fix no animation problem, becasue content are dynamically generated
      # make sure angular not add class until current scope life cycle complete
      $timeout (-> element.addClass 'mp-bottom-modalbox-show')
]


# mp-edit-project-modal
app.directive 'mpEditProjectModal', ['$templateCache', '$compile',
'$rootScope',
($templateCache, $compile, $rootScope) ->

  templateUrl: 'mp_edit_project_modal_template'
  scope: true
  link: (scope, element, attrs) ->
    scope.errorMessage = null

    scope.modalbox =
      title: scope.project.title
      notes: scope.project.notes

    scope.saveProject = ->
      if scope.modalbox.title.length > 0
        scope.errorMessage = null
        angular.extend scope.project, scope.modalbox
        _places = scope.project.places
        delete scope.project.places
        scope.project.put().then ->
          $rootScope.$broadcast 'projectUpdated'
          scope.closeModal()
        scope.project.places = _places
      else
        scope.errorMessage = "You must have a title to start with."

    scope.deleteProject = ->
      scope.errorMessage = null
      for project, index in scope.MpProjects.projects
        if project == scope.project
          scope.MpProjects.projects.splice index, 1
          break
      $rootScope.$broadcast 'projectRemoved'
      scope.closeModal()
]
