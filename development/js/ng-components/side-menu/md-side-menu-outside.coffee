app.directive 'mdSideMenuOutside', [->

  templateUrl:  '/scripts/ng-components/side-menu/md-side-menu-outside.html'
  replace:      true
  controllerAs: 'MdSideMenuOutsideCtrl'
  controller: ['$scope', 'MpUser', '$location', class MdSideMenuOutsideCtrl

    constructor: ($scope, MpUser, $location) ->
      @outsideActiveSection = 'register'

      @registerUser = (userData, fail) ->
        MpUser.emailRegister userData, (->
          $location.path '/dashboard'
        ), (failedInfo) ->
          fail(failedInfo) if fail

      @loginUser = (userData, fail) ->
        MpUser.emailLogin userData, (->
          $location.path '/dashboard'
        ), (failedInfo) ->
          fail(failedInfo) if fail
  ]
  link: (scope, element, attrs, MdSideMenuOutsideCtrl) ->

    element.on 'click', '.md-side-menu-actions-item-anchor', (event) ->
      scope.interface.showUserSection = false
      return # prevent return false
]
