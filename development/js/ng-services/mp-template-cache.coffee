app.factory 'mpTemplateCache', ['$templateCache', '$http', '$q', '$timeout',
($templateCache, $http, $q, $timeout) ->

  return {
    queue: {}
    get: (templatesUrl) ->
      deferred = $q.defer()
      template = $templateCache.get(templatesUrl)

      # tempalte doesn't exist
      if !template?
        # request already sent
        if @queue[templatesUrl]?
          @queue[templatesUrl].then (response) ->
            deferred.resolve(response.data)
        # no request yet
        else
          @queue[templatesUrl] = $http.get(templatesUrl)
          $timeout =>
            @queue[templatesUrl].then (response) =>
              delete @queue[templatesUrl]
              $templateCache.put(templatesUrl, response.data)
              deferred.resolve(response.data)

      # tempalte exist, but is a http response object
      else if angular.isArray(template)
        $templateCache.put(templatesUrl, template[1])
        $timeout -> deferred.resolve(template[1])

      # tempalte exist
      else
        $timeout -> deferred.resolve(template)

      return deferred.promise
  }
]
