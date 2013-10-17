app.directive 'mdEditProject',
['$routeSegment',
( $routeSegment)->

  templateUrl: ->
    return if $routeSegment.startsWith('ot') then '/scripts/views/_map/md-edit-project-m-outside.html' else '/scripts/views/_map/md-edit-project-m-inside.html'
  scope: true
  controllerAs: 'mdEditProjectCtrl'
  controller: ['$scope', '$element', 'MpProjects', '$location',
    ($scope, $element, MpProjects, $location) ->

      @editProjectForm = {
        title: ""
        notes: ""
        # deleteCheckbox
      }

      @loginWithFacebook = ->
        $element.removeClass('md-show')
        $scope.MpUser.login('/mobile/dashboard')

      @showSideMenu = ->
        $scope.interface.showUserSection = true
        $element.removeClass('md-show')

      @closeEditProjectForm = ->
        $element.removeClass('md-show')

      # Editing
      @revertChanges = ->
        @editProjectForm.title = $scope.mapCtrl.theProject.project.title
        @editProjectForm.notes = $scope.mapCtrl.theProject.project.notes
        @closeEditProjectForm()

      @saveChanges = ->
        if @editProjectForm.title.length == 0
          @formMessage = "You must have a title to start with."
        else
          @formMessage = ""
          $scope.mapCtrl.theProject.project.title = @editProjectForm.title
          $scope.mapCtrl.theProject.project.notes = @editProjectForm.notes
          $scope.mapCtrl.theProject.project.put()
          @closeEditProjectForm()

      @deleteProject = ->
        if @editProjectForm.deleteCheckbox
          $scope.insideViewCtrl.MpProjects.removeProject($scope.mapCtrl.theProject.project).then ->
            $location.path('/mobile/dashboard')

      # Return
      return
  ]
  link: (scope, element, attrs, mdEditProjectCtrl) ->

    element.next().on 'click', (event) ->
      element.removeClass('md-show')

    scope.$on 'showEditProjectDetailForm', ->
      element.addClass('md-show')

    scope.$watch 'mapCtrl.theProject.project.title', (newVal, oldVal) ->
      if newVal != mdEditProjectCtrl.editProjectForm.title
        mdEditProjectCtrl.editProjectForm.title = newVal

    scope.$watch 'mapCtrl.theProject.project.notes', (newVal, oldVal) ->
      if newVal != mdEditProjectCtrl.editProjectForm.notes
        mdEditProjectCtrl.editProjectForm.notes = newVal
]
