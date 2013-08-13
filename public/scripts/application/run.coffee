# run
app.run(['$rootScope', 'User', 'MpProjects', 'MpChatbox', 'TheMap',
($rootScope, User, MpProjects, MpChatbox, TheMap) ->

  User.then (User) ->
    $rootScope.User = User

  $rootScope.TheMap     = TheMap
  $rootScope.MpProjects = MpProjects
  $rootScope.MpChatbox  = MpChatbox

  $rootScope.interface = {}

  # events
  # $rootScope.$on '$routeChangeSuccess', (event, current) ->
  #   switch current.$$route.controller
  #     when 'OutsideViewCtrl'
  #       $rootScope.inMapview = true
  #     when 'AllProjectsViewCtrl'
  #       $rootScope.inMapview = false
  #     when 'NewProjectViewCtrl'
  #       $rootScope.inMapview = true
  #     when 'ProjectViewCtrl'
  #       $rootScope.inMapview = true
])
