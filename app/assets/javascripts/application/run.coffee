# run
app.run(['$rootScope', '$route',
($rootScope, $route) ->

  ###
  Assign previous route to $route.previous, so other services has access to
    previous route infomation on $route object when routing
  ###
  $rootScope.$on '$routeChangeStart', (event, future, current) ->
    $route.previous = if current then current.$$route else undefined

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
