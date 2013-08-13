# mp-control-toolbar
# ========================================
app.directive 'mpControlToolbar', ['$templateCache', '$compile',
($templateCache, $compile) ->

  link: (scope, element, attrs) ->

    scope.$on '$routeChangeSuccess', (event, current) ->
      switch current.$$route.controller
        when 'OutsideViewCtrl'
          template = $templateCache.get 'mp_control_toolbar_mapview_template'
        when 'AllProjectsViewCtrl'
          template = $templateCache.get 'mp_control_toolbar_all_project_view_template'
        when 'NewProjectViewCtrl'
          template = $templateCache.get 'mp_control_toolbar_inside_mapview_template'
        when 'ProjectViewCtrl'
          template = $templateCache.get 'mp_control_toolbar_inside_mapview_template'

      html = $compile(template)(scope)
      element.html html
]
