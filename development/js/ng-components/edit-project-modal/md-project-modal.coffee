app.directive 'mdProjectModal',
[->

  templateUrl: '/scripts/ng-components/edit-project-modal/md-project-modal.html'

  controllerAs: 'MdProjectModalCtrl'
  controller: ['$scope','$location','MpFriends','MapPlaces','MpUI','MpProjects',
  class MdProjectModalCtrl

    constructor: ($scope, $location, MpFriends, MapPlaces, MpUI, MpProjects) ->

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
      @removeUserFromProject = (user) ->
        TheProject.removeParticipatingUser(user)


      # --- Add user ---
      # generate an array of not participating friends, each element is a deep
      # of friends objects in MpFriends service
      $scope.$watch (=>
        return [MpUI.showProjectModal, MpUI.projectModalContent]
      ), ((newVal) =>
        if MpUI.showProjectModal == true &&
        MpUI.projectModalContent == 'inviteFriends'
          participatedUserIds = _.pluck(MapPlaces.participatedUsers, 'id')
          @_notParticipatingFriends = []
          for friend in MpFriends.friends
            if _.indexOf(participatedUserIds, friend.id) < 0
              @_notParticipatingFriends.push _.cloneDeep(friend)
      ), true

      @getSelectedNotParticipatingUsers = ->
        return _.filter(@_notParticipatingFriends, '$selected')

      @sendInvitationToSelectedUsers = ->
        selectedUsers = _.filter(@_notParticipatingFriends, '$selected')
        if selectedUsers.length
          MapPlaces.addParticipatedUsers selectedUsers
  ]

  link: (scope, element, attrs, MdProjectModalCtrl) ->
]
