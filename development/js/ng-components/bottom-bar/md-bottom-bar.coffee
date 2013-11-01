app.directive 'mdBottomBar', [->

  templateUrl: '/scripts/ng-components/bottom-bar/md-bottom-bar.html'
  replace:     true

  controllerAs: 'MdBottomBarCtrl'
  controller: ['$scope','$routeSegment','MapPlaces','MpUI', class MdBottomBarCtrl

    constructor: ($scope, $routeSegment, MapPlaces, MpUI) ->

      # change bottom bar inner when user navigate
      $scope.$watch (->
        return $routeSegment.name
      ), (newVal) =>
        switch newVal
          when 'ot'
            templateName = 'ot-project'
          when 'in.dashboard'
            templateName = 'in-dashboard'
          when 'in.project'
            templateName = 'in-project'
          when 'in.friends'
            templateName = 'in-friends'
          when 'in.search'
            templateName = 'in-search'
        @contentTemplateUrl = "/scripts/ng-components/bottom-bar/md-bottom-bar-#{templateName}.html" if templateName?


      # --- Listeners ---
      $scope.$watch (->
        return MapPlaces.project?.get('title')
      ), (newVal) =>
        @projectTitle = newVal if newVal?


      # --- Actions ---
      @toggleSearchResultsList = ->
        if MpUI.mapDrawerActiveSection == 'searchResults' && MpUI.showMapDrawer
          MpUI.showMapDrawer = false
        else
          MpUI.mapDrawerActiveSection = 'searchResults'
          MpUI.showMapDrawer = true
  ]

  link: (scope, element, attrs, MdBottomBarCtrl) ->
]
