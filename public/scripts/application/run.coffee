# run
app.run(['$rootScope', '$location', 'User', 'MpProjects', 'MpChatbox',
($rootScope, $location, User, MpProjects, MpChatbox) ->

  User.then (User) ->
    $rootScope.User = User

  $rootScope.MpProjects = MpProjects
  $rootScope.MpChatbox = MpChatbox

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
