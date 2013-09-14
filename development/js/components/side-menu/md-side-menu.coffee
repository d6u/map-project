app.directive 'mdSideMenu',
['$routeSegment', ($routeSegment) ->

  templateUrl: ->
    if $routeSegment.startsWith('ot') then '/scripts/views/_pusher-side/md-side-menu-outside.html' else '/scripts/views/_pusher-side/md-side-menu-inside.html'
  replace: true
  controllerAs: 'mdSideMenuCtrl'
  controller: ['$scope', ($scope) ->


    return
  ]
  link: (scope, element, attrs, mdSideMenuCtrl) ->

    element.find('.md-side-menu-actions-item-anchor').on 'click', (event) ->
      scope.interface.showUserSection = false
      return # prevent return false
]
