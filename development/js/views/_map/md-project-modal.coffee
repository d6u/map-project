app.directive 'mdProjectModal',
[->
  templateUrl: '/scripts/views/_map/md-project-modal.html'
  controllerAs: 'mdProjectModalCtrl'
  controller: ['$scope', '$location', ($scope, $location) ->

    @showModal         = false
    @bodyContent       = 'editDetail'
    @addFriendsSection = 'all'

    # --- Edit project tab ---
    @_projectAttrs = {
      title: ""
      notes: ""
      deleteCheckbox: false
    }

    @revertChanges = ->
      @_projectAttrs.title = $scope.mapCtrl.theProject.project.title
      @_projectAttrs.notes = $scope.mapCtrl.theProject.project.notes
      @showModal           = false

    @saveChanges = ->
      if @_projectAttrs.title.length == 0
        @_projectAttrs.errorMessage = "You must have a title to start with."
      else
        @_projectAttrs.errorMessage = null
        $scope.mapCtrl.theProject.project.title = @_projectAttrs.title
        $scope.mapCtrl.theProject.project.notes = @_projectAttrs.notes
        $scope.mapCtrl.theProject.project.put()
        @showModal = false

    @deleteProject = ->
      if @_projectAttrs.deleteCheckbox
        $scope.insideViewCtrl.MpProjects.removeProject($scope.mapCtrl.theProject.project).then ->
          $location.path('/home')

    # reset deleteCheckbox when interface changes
    $scope.$watch (=>
      return [@showModal, @bodyContent]
    ), ((newVal) =>
      @_projectAttrs.deleteCheckbox = false
      if @showModal == true && @bodyContent == 'editDetail'
        @_projectAttrs.title = $scope.mapCtrl.theProject.project.title
        @_projectAttrs.notes = $scope.mapCtrl.theProject.project.notes
    ), true

    # --- Manage participants ---


    # --- Add user ---
    $scope.$watch (=>
      return [@showModal, @bodyContent]
    ), ((newVal) =>
      if @showModal == true && @bodyContent == 'inviteFriends'
        participatedUserIds = _.pluck($scope.mapCtrl.theProject.participatedUsers, 'id')
        @_notParticipatingFriends = []
        for friend in $scope.insideViewCtrl.mpFriends.friends
          if _.find(participatedUserIds, friend.id)
            @_notParticipatingFriends.push _.cloneDeep(friend)
    ), true

    @getSelectedNotParticipatingUsers = ->
      return _.filter(@_notParticipatingFriends, '$selected')

    @sendInvitationToSelectedUsers = ->
      selectedUsers = _.filter(@_notParticipatingFriends, '$selected')
      if selectedUsers.length
        $scope.mapCtrl.theProject.addParticipatedUsers selectedUsers

    # --- Return ---
    return
  ]
  link: (scope, element, attrs, mdProjectModalCtrl) ->

    element.next().on 'click', (event) ->
      scope.$apply ->
        mdProjectModalCtrl.showModal = false
]
