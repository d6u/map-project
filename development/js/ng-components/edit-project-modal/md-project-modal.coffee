app.directive 'mdProjectModal',
[->

  templateUrl: '/scripts/ng-components/edit-project-modal/md-project-modal.html'

  controllerAs: 'MdProjectModalCtrl'
  controller: ['$scope','$location','MpFriends','MapPlaces','MpUI','MpProjects',
  'ParticipatingUsers','$http','$routeSegment',
  class MdProjectModalCtrl

    constructor: ($scope, $location, MpFriends, MapPlaces, MpUI, MpProjects, ParticipatingUsers, $http, $routeSegment) ->

      @addFriendsSection = 'all'


      # --- Edit project tab ---
      @_projectAttrs = {
        title: ""
        notes: ""
        deleteCheckbox: false
      }

      @revertChanges = ->
        @_projectAttrs.title = MapPlaces.project.get('title')
        @_projectAttrs.notes = MapPlaces.project.get('notes')
        MpUI.showProjectModal = false

      @saveChanges = ->
        if @_projectAttrs.title.length == 0
          @_projectAttrs.errorMessage = "You must have a title to start with."
        else
          @_projectAttrs.errorMessage = null
          MapPlaces.project.set({
            title: @_projectAttrs.title
            notes: @_projectAttrs.notes
          })
          MapPlaces.project.save()
          MpUI.showProjectModal = false

      @deleteProject = ->
        if @_projectAttrs.deleteCheckbox
          MapPlaces.project.destroy()
          $location.path('/home')
          MpUI.showProjectModal = false

      # reset deleteCheckbox when interface changes
      $scope.$watch (=>
        return [MpUI.showProjectModal, MpUI.projectModalContent]
      ), ((newVal) =>
        @_projectAttrs.deleteCheckbox = false
        if MpUI.showProjectModal == true &&
        MpUI.projectModalContent == 'editDetail'
          @_projectAttrs.title = MapPlaces.project.get('title')
          @_projectAttrs.notes = MapPlaces.project.get('notes')
      ), true


      # --- Manage participants ---
      $scope.$watch (->
        return ParticipatingUsers.models
      ), =>
        @participatingUsers = ParticipatingUsers.models


      @removeUserFromProject = (user) ->
        ParticipatingUsers.remove(user)


      # --- Add user ---
      # generate an array of not participating friends, each element is a deep
      # of friends objects in MpFriends service
      $scope.$watch (=>
        return [MpUI.showProjectModal, MpUI.projectModalContent]
      ), ((newVal) =>
        if MpUI.showProjectModal == true &&
        MpUI.projectModalContent == 'inviteFriends'
          participating_user_ids = ParticipatingUsers.pluck('id')
          @_notParticipatingFriends = []
          for friend in MpFriends.models
          # for friend in MpFriends.filter((friend) -> friend.get('status') > 0)
            if _.indexOf(participating_user_ids, friend.id) < 0
              @_notParticipatingFriends.push( friend.clone() )
      ), true


      @getSelectedNotParticipatingUsers = ->
        return _.filter(@_notParticipatingFriends, '$selected')


      @sendInvitationToSelectedUsers = ->
        selectedUsers = _.filter(@_notParticipatingFriends, '$selected')
        if selectedUsers.length
          MpUI.showProjectModal = false
          ids = _.pluck(selectedUsers, 'id')
          $http.post("/api/projects/#{$routeSegment.$routeParams.project_id}/add_users", {user_ids: ids.join(',')})
  ]

  link: (scope, element, attrs, MdProjectModalCtrl) ->
]
