# mp-edit-project-form
app.directive 'mpEditProjectForm', ['$rootScope', '$location',
($rootScope, $location) ->

  scope: true
  link: (scope, element, attrs) ->

    scope.deleteProject = ->
      scope.MpProjects.removeProject(scope.TheProject.project).then ->
        $location.path('/home')

    scope.saveChanges = ->
      if scope.editProject.title.length == 0
        scope.editProject.errorMessage = "You must have a title to start with."
      else
        scope.editProject.errorMessage = null
        scope.TheProject.project.title = scope.editProject.title
        scope.TheProject.project.notes = scope.editProject.notes
        scope.TheProject.project.put()

    scope.revertChanges = ->
      scope.editProject.title = scope.TheProject.project.title
      scope.editProject.notes = scope.TheProject.project.notes


    # init
    # ----------------------------------------
    # form object => editProjectForm
    scope.editProject = {}

    scope.$watch 'TheProject.project.title', (newVal, oldVal) ->
      if newVal != scope.editProject.title
        scope.editProject.title = newVal

    scope.$watch 'TheProject.project.notes', (newVal, oldVal) ->
      if newVal != scope.editProject.notes
        scope.editProject.notes = newVal
]
