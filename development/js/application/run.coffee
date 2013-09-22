# run
app.run(['$rootScope', ($rootScope) ->

  # Values used to assign classes
  $rootScope.interface = {
    showUserSection: false
  }

  firstTime = $rootScope.$on '$routeChangeSuccess', ->
    NProgress.done()
    firstTime()

    $rootScope.$on '$routeChangeStart', ->
      NProgress.start()

    $rootScope.$on '$routeChangeSuccess', ->
      NProgress.done()
])
