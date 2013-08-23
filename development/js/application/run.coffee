# run
app.run(['$rootScope', '$route',
($rootScope, $route) ->

  ###
  Assign previous route to $route.previous, so other services has access to
    previous route infomation on $route object when routing
  ###
  $rootScope.$on '$routeChangeStart', (event, future, current) ->
    $route.previous = if current then current.$$route else undefined

  # Values used to assign classes
  $rootScope.interface = {
    showUserSection: false
    centerSearchBar: true
  }
])
