app.directive 'mdEditProject',
['$routeSegment',
( $routeSegment)->

  templateUrl: (->
    return if $routeSegment.startsWith('ot') then '/scripts/views/_map/md-edit-project-m-outside.html' else '/scripts/views/_map/md-edit-project-m-inside.html'
  )()
  controllerAs: 'mdEditProjectCtrl'
  controller: ['$scope', '$element', ($scope, $element) ->

    @loginWithFacebook = ->
      $element.removeClass('md-show')
      $scope.MpUser.login('/home')

    @showSideMenu = ->
      $scope.interface.showUserSection = true
      $element.removeClass('md-show')

    @closeEditProjectForm = ->
      $element.removeClass('md-show')

    return
  ]
  link: (scope, element, attrs) ->

    element.next().on 'click', (event) ->
      element.removeClass('md-show')
]
