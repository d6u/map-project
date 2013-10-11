app.directive 'mdChatbox',
['mpTemplateCache','$compile','$timeout','ChatHistories',
( mpTemplateCache,  $compile,  $timeout,  ChatHistories) ->

  templateUrl: '/scripts/ng-components/chatbox/md-chatbox.html'
  replace: true

  controllerAs: 'MdChatboxCtrl'
  controller: ['$element', '$scope', 'TheProject', '$routeSegment',
  'ParticipatingUsers', class MdChatboxCtrl

    constructor: ($element, $scope, TheProject, $routeSegment, ParticipatingUsers) ->

      # --- Init ---
      @participatedUsers = ParticipatingUsers.models
      @chatHistories     = ChatHistories.models


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
