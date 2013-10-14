app.directive 'mdChatbox',
[->

  templateUrl: '/scripts/ng-components/chatbox/md-chatbox.html'
  replace: true

  controllerAs: 'MdChatboxCtrl'
  controller: ['$scope', 'ParticipatingUsers', 'ChatHistories', class MdChatboxCtrl

    constructor: ($scope, ParticipatingUsers, ChatHistories) ->

      # --- Init ---
      $scope.$watch (-> ChatHistories.models), (newVal, oldVal) =>
        @chatHistories = newVal

      $scope.$watch (-> ParticipatingUsers.models), (newVal, oldVal) =>
        @participatedUsers = newVal


      # --- Events ---
      $scope.$on 'enterNewMessage', (event, message) ->
        ChatHistories.create({
          item_type: 0
          content:
            m: message
        }, {selfSender: true})
        event.stopPropagation()
  ]

  link: (scope, element, attrs, MdChatboxCtrl) ->
]
