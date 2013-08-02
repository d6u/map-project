app = angular.module('angular-mp.home.index.controller', [])


# NewProjectModalCtrl
app.controller('NewProjectModalCtrl',
['$scope', '$element', 'Project', '$rootScope',
($scope, $element, Project, $rootScope) ->
  $element.find('#new_project_modal_save').on 'click', ->
    if $scope.newProjectModalForm.$valid
      $scope.$apply -> $scope.errorMessage = null
      project = new Project($scope.newProjectModal)
      project.$save ->
        $rootScope.$broadcast('newProjectCreated', project)
        $element.modal('hide')
    else
      $scope.$apply -> $scope.errorMessage = "You must have a title to start with"
])
