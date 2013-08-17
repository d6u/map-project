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
        scope.MpProjects.currentProject.put().then (project) ->
          $location.path('/project/'+project.id) if $location.path() == '/new_project'
          $rootScope.$broadcast 'projectUpdated'

    scope.revertChanges = ->
      scope.editProject.title = scope.MpProjects.currentProject.title
      scope.editProject.notes = scope.MpProjects.currentProject.notes


    # init
    # ----------------------------------------
    # form object => editProjectForm
    scope.editProject = {}

    scope.$watch 'MpProjects.currentProject.title', (newVal, oldVal) ->
      if newVal != scope.editProject.title
        scope.editProject.title = newVal

    scope.$watch 'MpProjects.currentProject.notes', (newVal, oldVal) ->
      if newVal != scope.editProject.notes
        scope.editProject.notes = newVal
]
