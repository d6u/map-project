# run
app.run(['$rootScope', '$http', 'MpUI', ($rootScope, $http, MpUI) ->

  # --- UI ---
  $rootScope.MpUI = MpUI

  firstTime = $rootScope.$on '$routeChangeSuccess', ->
  NProgress.done()
  firstTime()

  $rootScope.$on '$routeChangeStart', ->
    NProgress.start()

  $rootScope.$on '$routeChangeSuccess', ->
    NProgress.done()


  # --- Backbone ---
  Backbone.sync = (method, model, options) ->
    url = if typeof model.url == "function" then model.url() else model.url
    switch method
      when 'create'
        request = $http.post   url, model
      when 'read'
        request = $http.get    url
      when 'update'
        request = $http.put    url, model
      when 'delete'
        request = $http.delete url
    request.success(options.success).error(options.error)
])
