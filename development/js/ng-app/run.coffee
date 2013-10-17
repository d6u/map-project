# run
app.run(['$rootScope', 'MpUI', ($rootScope, MpUI) ->

  # --- UI ---
  $rootScope.MpUI = MpUI

  firstTime = $rootScope.$on '$routeChangeSuccess', ->
  NProgress.done()
  firstTime()

  $rootScope.$on '$routeChangeStart', ->
    NProgress.start()

  $rootScope.$on '$routeChangeSuccess', ->
    NProgress.done()
])
