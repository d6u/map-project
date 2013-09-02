# md-edit-project
app.directive 'mdEditProject',
['$rootScope', '$location',
( $rootScope,   $location) ->

  templateUrl: ->
    return if $location.path() == '/' then '/scripts/views/_map/md-edit-project-outside.html' else '/scripts/views/_map/md-edit-project-inside.html'
  scope: true
  controllerAs: 'editProjectCtrl'
  controller: ['$scope', '$location', ($scope, $location) ->

    @editProjectForm = {
      title: ""
      notes: ""
      # deleteCheckbox
    }

    # Editing
    @revertChanges = ->
      @editProjectForm.title = $scope.mapCtrl.theProject.project.title
      @editProjectForm.notes = $scope.mapCtrl.theProject.project.notes
      $scope.drawerCtrl.showEditProjectSubsection = false

    @saveChanges = ->
      if @editProjectForm.title.length == 0
        @editProjectForm.errorMessage = "You must have a title to start with."
      else
        @editProjectForm.errorMessage = null
        $scope.mapCtrl.theProject.project.title = @editProjectForm.title
        $scope.mapCtrl.theProject.project.notes = @editProjectForm.notes
        $scope.mapCtrl.theProject.project.put()
        $scope.drawerCtrl.showEditProjectSubsection = false

    @deleteProject = ->
      if @editProjectForm.deleteCheckbox
        $scope.insideViewCtrl.MpProjects.removeProject($scope.mapCtrl.theProject.project).then ->
          $location.path('/home')

    return
  ]
  link: (scope, element, attrs, editProjectCtrl) ->

    element.find('#invite-friends-button').on 'click', (event) ->
      $rootScope.$broadcast 'showProjectAddFriendsModal'

    scope.$watch 'mapCtrl.theProject.project.title', (newVal, oldVal) ->
      if newVal != editProjectCtrl.editProjectForm.title
        editProjectCtrl.editProjectForm.title = newVal

    scope.$watch 'mapCtrl.theProject.project.notes', (newVal, oldVal) ->
      if newVal != editProjectCtrl.editProjectForm.notes
        editProjectCtrl.editProjectForm.notes = newVal
]
