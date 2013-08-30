app.directive 'mdMenu',
['$routeSegment', ($routeSegment) ->

  templateUrl: (->
    return if $routeSegment.startsWith('ot') then '/scripts/views/_menu/md-menu-m-outside.html' else '/scripts/views/_menu/md-menu-m-inside.html'
  )()
  controllerAs: 'mdMenuCtrl'
  controller: [->


  ]
  link: (scope, element, attrs) ->


]
