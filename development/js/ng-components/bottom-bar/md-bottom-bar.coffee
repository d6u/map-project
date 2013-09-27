app.directive 'mdBottomBar',
[->

  templateUrl: '/scripts/components/bottom-bar/md-bottom-bar.html'
  replace: true
  controllerAs: 'MdBottomBarCtrl'
  controller: ['$scope', 'MpNotification', class MdBottomBarCtrl

    constructor: ($scope, MpNotification) ->

  ]
  link: (scope, element, attrs, MdBottomBarCtrl) ->
]
