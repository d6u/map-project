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

    @deleteProject = ->
      if @editProjectForm.deleteCheckbox
        $scope.MpProjects.removeProject($scope.TheProject.project).then ->
          $location.path('/home')

    @saveChanges = ->
      if @editProjectForm.title.length == 0
        @editProjectForm.errorMessage = "You must have a title to start with."
      else
        @editProjectForm.errorMessage = null
        $scope.TheProject.project.title = @editProjectForm.title
        $scope.TheProject.project.notes = @editProjectForm.notes
        $scope.TheProject.project.put()
        $scope.drawerCtrl.showEditProjectSubsection = false

    @revertChanges = ->
      @editProjectForm.title = $scope.TheProject.project.title
      @editProjectForm.notes = $scope.TheProject.project.notes
      $scope.drawerCtrl.showEditProjectSubsection = false

    return
  ]
  link: (scope, element, attrs, editProjectCtrl) ->

    element.find('#invite-friends-button').on 'click', (event) ->
      $rootScope.$broadcast 'showProjectAddFriendsModal'

    scope.$watch 'TheProject.project.title', (newVal, oldVal) ->
      if newVal != editProjectCtrl.editProjectForm.title
        editProjectCtrl.editProjectForm.title = newVal

    scope.$watch 'TheProject.project.notes', (newVal, oldVal) ->
      if newVal != editProjectCtrl.editProjectForm.notes
        editProjectCtrl.editProjectForm.notes = newVal
]
