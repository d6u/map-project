app.factory 'mpTemplateCache', ['$templateCache', '$http', '$q', '$timeout',
($templateCache, $http, $q, $timeout) ->

  return {
    get: (templatesUrl) ->
      deferred = $q.defer()
      template = $templateCache.get(templatesUrl)
      if !template
        $http.get(templatesUrl).then (html) ->
          $templateCache.put(templatesUrl, html.data)
          deferred.resolve(html.data)
      else if angular.isArray(template)
        $templateCache.put(templatesUrl, template[1])
        deferred.resolve(template[1])
      else
        $timeout -> deferred.resolve(template)
      return deferred.promise
  }
]
