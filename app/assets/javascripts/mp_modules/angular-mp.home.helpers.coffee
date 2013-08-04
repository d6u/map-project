app = angular.module 'angular-mp.home.helpers', []


# project-detail-modal
app.directive 'projectDetailModal', ['$rootScope', 'Project', '$location',
($rootScope, Project, $location) ->
  (scope, element, attrs) ->

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

    scope.$on 'editProjectAttrs', (event, data) ->
      scope.hideDeleteProjectButton = false
      if data
        scope.newProjectModal = data
      else
        scope.newProjectModal = {}
      element.trigger('openModal')
]
