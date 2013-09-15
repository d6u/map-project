app.controller 'OutsideViewCtrl',
['$scope', 'MpUser', class OutsideViewCtrl

  constructor: ($scope, MpUser) ->
    @hideHomepage = false

    @showScreenShot = ->
      # TODO: move out of controller
      $('.md-homepage-content').animate({scrollTop: $('.md-homepage-intro-bg').offset().top}, 200)

    @loginWithFacebook = ->
      MpUser.login '/dashboard', ->
        $scope.interface.showUserSection = false
]
