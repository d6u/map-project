app = angular.module 'angular-mp.home.helpers', []


# project-detail-modal
app.directive 'projectDetailModal', ['$rootScope', 'Project', '$location',
($rootScope, Project, $location) ->
  (scope, element, attrs) ->

    scope.hideDeleteProjectButton = true

    scope.$on 'editProjectDetails', (event, project) ->
      scope.newProjectModal = project
      scope.hideDeleteProjectButton = false
      element.modal()

    scope.saveProject = ->
      if scope.newProjectModalForm.$valid
        scope.errorMessage = null
        Project.update scope.newProjectModal, (project) ->
          $rootScope.$broadcast 'projectUpdated', project
          element.modal('hide')
          scope.hideDeleteProjectButton = true
      else
        scope.errorMessage = "You must have a title to start with."

    # TODO: refactor
    $rootScope.$on 'newProject', ->
      element.modal()

    scope.deleteProject = ->
      scope.errorMessage = null
      Project.delete {project_id: scope.newProjectModal.id}, ->
        $rootScope.$broadcast 'projectDeleted', scope.newProjectModal.id
        element.modal('hide')
        $location.path('/all_projects')
        scope.newProjectModal = {}
        scope.hideDeleteProjectButton = true
]
