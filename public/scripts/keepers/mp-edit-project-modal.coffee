# mp-edit-project-modal
app.directive 'mpEditProjectModal', ['$templateCache', '$compile',
'$rootScope',
($templateCache, $compile, $rootScope) ->

  templateUrl: 'mp_edit_project_modal_template'
  scope: true
  link: (scope, element, attrs) ->
    scope.errorMessage = null

    scope.modalbox =
      title: scope.project.title
      notes: scope.project.notes

    scope.saveProject = ->
      if scope.modalbox.title.length > 0
        scope.errorMessage = null
        angular.extend scope.project, scope.modalbox
        _places = scope.project.places
        _partcipatedUsers = scope.project.partcipatedUsers
        delete scope.project.places
        delete scope.project.partcipatedUsers
        scope.project.put().then ->
          $rootScope.$broadcast 'projectUpdated'
          scope.closeModal()
        scope.project.places = _places
        scope.project.partcipatedUsers = _partcipatedUsers
      else
        scope.errorMessage = "You must have a title to start with."

    scope.deleteProject = ->
      scope.errorMessage = null
      scope.MpProjects.projects = _.without scope.MpProjects.projects, scope.project
      $rootScope.$broadcast 'projectRemoved'
      scope.closeModal()
]
