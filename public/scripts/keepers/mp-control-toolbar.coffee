# mp-control-toolbar
# ========================================
app.directive 'mpControlToolbar', ['$templateCache', '$compile', '$route',
'$timeout', 'mpTemplateCache',
($templateCache, $compile, $route, $timeout, mpTemplateCache) ->

  currentTemplate = ->
    switch $route.current.$$route.controller
      when 'OutsideViewCtrl'
        return 'scripts/keepers/mp-control-toolbar-mapview.html'
      when 'AllProjectsViewCtrl'
        return 'scripts/keepers/mp-control-toolbar-all-project-view.html'
      when 'NewProjectViewCtrl'
        return 'scripts/keepers/mp-control-toolbar-mapview-inside.html'
      when 'ProjectViewCtrl'
        return 'scripts/keepers/mp-control-toolbar-mapview-inside.html'

  return {
    compile: (element, attrs, transclude) ->
      console.log transclude
      return (scope, element, attrs) ->
        mpTemplateCache.get(currentTemplate()).then (template) ->
          element.html $compile(template)(scope)
    link: (scope, element, attrs) ->

  }
]
