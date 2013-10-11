app.directive 'mdChatbox',
['mpTemplateCache','$compile','$timeout','MpChat',
( mpTemplateCache,  $compile,  $timeout,  MpChat) ->

  templateUrl: '/scripts/ng-components/chatbox/md-chatbox.html'
  replace: true

  controllerAs: 'MdChatboxCtrl'
  controller: ['$element', '$scope', 'TheProject', '$routeSegment',
  'ParticipatingUsers', class MdChatboxCtrl

    constructor: ($element, $scope, TheProject, $routeSegment,
    ParticipatingUsers) ->

      # --- Init ---
      # @MpChat = MpChat

      # MpChat.initialize($scope)

      if $routeSegment.$routeParams.project_id?
        @ParticipatingUsers = ParticipatingUsers
        ParticipatingUsers.loadProject($scope, $routeSegment.$routeParams.project_id)
        ParticipatingUsers.fetch()
  ]

  link: (scope, element, attrs, MdChatboxCtrl) ->
]
