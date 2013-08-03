app = angular.module 'angular-mp.home.helpers', []


# project-detail-modal
app.directive 'projectDetailModal', ['$rootScope', 'Project', '$location',
($rootScope, Project, $location) ->
  (scope, element, attrs) ->

    scope.hideDeleteProjectButton = true

    scope.$on 'newProject', ->
      element.modal()

    scope.$on 'editProjectDetails', (event, project) ->
      scope.newProjectModal = project
      scope.hideDeleteProjectButton = false
      element.modal()

    scope.saveProject = ->
      if scope.newProjectModalForm.$valid
        scope.errorMessage = null
        Project.save scope.newProjectModal, (project) ->
          $rootScope.$broadcast 'newProjectCreated', project
          element.modal('hide')
          scope.hideDeleteProjectButton = true
      else
        scope.errorMessage = "You must have a title to start with."

    scope.deleteProject = ->
      scope.errorMessage = null
      Project.delete {project_id: scope.newProjectModal.id}, ->
        $rootScope.$broadcast 'projectDeleted', scope.newProjectModal.id
        element.modal('hide')
        $location.path('/')
        scope.newProjectModal = {}
        scope.hideDeleteProjectButton = true
]
