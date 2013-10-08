app.directive 'mdBottomBar', [->

  templateUrl: '/scripts/ng-components/bottom-bar/md-bottom-bar.html'
  replace:     true

  controllerAs: 'MdBottomBarCtrl'
  controller: ['$scope', 'MpNotification', '$routeSegment', class MdBottomBarCtrl

    constructor: ($scope, MpNotification, $routeSegment) ->

      # change bottom bar inner when user navigate
      $scope.$watch (->
        return $routeSegment.name
      ), (newVal) =>
        switch newVal
          when 'ot'
            @contentTemplateUrl = '/scripts/ng-components/bottom-bar/md-bottom-bar-ot-project.html'
          when 'in.dashboard'
            @contentTemplateUrl = '/scripts/ng-components/bottom-bar/md-bottom-bar-in-dashboard.html'
          when 'in.project'
            @contentTemplateUrl = '/scripts/ng-components/bottom-bar/md-bottom-bar-ot-project.html'
          when 'in.friends'
            @contentTemplateUrl = ''
          when 'in.search'
            @contentTemplateUrl = ''
  ]

  link: (scope, element, attrs, MdBottomBarCtrl) ->
]
