# mp-edit-project-form
app.directive 'mpEditProjectForm', ['$rootScope', '$location',
($rootScope, $location) ->

  scope: true
  link: (scope, element, attrs) ->

    scope.deleteProject = ->
      scope.editProject.errorMessage = null
      scope.MpProjects.projects = _.without scope.MpProjects.projects, scope.MpProjects.currentProject
      $location.path('/all_projects')

    scope.saveChanges = ->
      if scope.editProject.title.length == 0
        scope.editProject.errorMessage = "You must have a title to start with."
      else
        scope.editProject.errorMessage = null
        scope.MpProjects.currentProject.title = scope.editProject.title
        scope.MpProjects.currentProject.notes = scope.editProject.notes
        _places = scope.MpProjects.currentProject.places
        delete scope.MpProjects.__currentProjectPlaces
        delete scope.MpProjects.currentProject.places
        scope.MpProjects.currentProject.put().then ->
          $rootScope.$broadcast 'projectUpdated'
        scope.MpProjects.currentProject.places = _places
        scope.MpProjects.__currentProjectPlaces = _places

    scope.revertChanges = ->
      scope.editProject.title = scope.MpProjects.currentProject.title
      scope.editProject.notes = scope.MpProjects.currentProject.notes


    # init
    # ----------------------------------------
    # editProjectForm
    scope.editProject = {}

    scope.$watch 'MpProjects.currentProject.title', (newVal, oldVal) ->
      if newVal != scope.editProject.title
        scope.editProject.title = newVal

    scope.$watch 'MpProjects.currentProject.notes', (newVal, oldVal) ->
      if newVal != scope.editProject.notes
        scope.editProject.notes = newVal
]
