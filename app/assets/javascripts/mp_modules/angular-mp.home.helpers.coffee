app = angular.module 'angular-mp.home.helpers', []


# project-detail-modal
app.directive 'projectDetailModal', ['$rootScope', 'Project', '$location',
($rootScope, Project, $location) ->
  (scope, element, attrs) ->

    if $location.path() == '/new_project' then scope.inNewPorject = true else scope.inNewPorject = false

    element.easyModal({
      overlayClose: false
      closeOnEscape: false
      })

    scope.hideDeleteProjectButton = true

    scope.saveProject = ->
      if scope.newProjectModalForm.$valid
        scope.errorMessage = null
        Project.update scope.newProjectModal, (project) ->
          $rootScope.$broadcast 'projectUpdated', project
          element.trigger('closeModal')
          scope.hideDeleteProjectButton = true
          scope.inNewPorject = false
      else
        scope.errorMessage = "You must have a title to start with."

    scope.deleteProject = ->
      scope.errorMessage = null
      Project.delete {project_id: scope.newProjectModal.id}, ->
        $rootScope.$broadcast 'projectDeleted', scope.newProjectModal.id
        element.trigger('closeModal')
        $location.path('/all_projects')
        scope.newProjectModal = {}
        scope.hideDeleteProjectButton = true
        scope.inNewPorject = false

    scope.cancelEdit = ->
      element.trigger('closeModal')
      scope.errorMessage = null
      scope.hideDeleteProjectButton = true
      scope.inNewPorject = false

    scope.$on 'editProjectAttrs', (event, data) ->
      scope.hideDeleteProjectButton = false
      if data
        console.log data
        scope.newProjectModal =
          id: data.id
          title: data.title
          notes: data.notes
      else
        scope.newProjectModal = {}
      element.trigger('openModal')
]
