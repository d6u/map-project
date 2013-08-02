app = angular.module 'angular-mp.home.helpers', []


# project-detail-modal
app.directive 'projectDetailModal', ['$rootScope', 'Project',
($rootScope, Project) ->
  (scope, element, attrs) ->

    scope.$on 'newProject', ->
      element.modal()

    scope.saveProject = ->
      if scope.newProjectModalForm.$valid
        scope.errorMessage = null
        Project.save scope.newProjectModal, (project) ->
          $rootScope.$broadcast 'newProjectCreated', project
          element.modal('hide')
      else
        scope.errorMessage = "You must have a title to start with."
]
