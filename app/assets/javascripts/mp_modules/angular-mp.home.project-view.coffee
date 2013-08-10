app = angular.module 'angular-mp.home.project-view', []


app.controller 'ProjectViewCtrl',
['$scope', 'MpProjects', 'TheMap', '$location', '$route', '$rootScope',
'$routeParams',
($scope, MpProjects, TheMap, $location, $route, $rootScope, $routeParams) ->

  if MpProjects.projects.length == 0
    MpProjects.getProjects({include_participated: true}).then ->
      if MpProjects.projects.length == 0
        $location.path('/new_project')
      else
        project = _.find MpProjects.projects, (prj) ->
          prj.id == Number($routeParams.project_id)
        MpProjects.setCurrentProject project


  # events
  $scope.$on 'projectRemoved', (event) ->
    $location.path('/all_projects')
]
