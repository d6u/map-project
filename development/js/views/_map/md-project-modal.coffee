app.directive 'mdProjectModal',
[->
  templateUrl: '/scripts/views/_map/md-project-modal.html'
  controllerAs: 'mdProjectModalCtrl'
  controller: ['$scope', ($scope) ->

    @showModal         = false
    @bodyContent       = 'editDetail'
    @addFriendsSection = 'all'

    @getNotParticipatingFriends = ->
      return []
  ]
  link: (scope, element, attrs, mdProjectModalCtrl) ->

    element.next().on 'click', (event) ->
      scope.$apply ->
        mdProjectModalCtrl.showModal = false
]
