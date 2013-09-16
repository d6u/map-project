app.controller 'OutsideViewCtrl',
['$scope', 'MpUser', 'TheProject', 'MpProjects', '$q', class OutsideViewCtrl

  constructor: ($scope, MpUser, TheProject, MpProjects, $q) ->
    @hideHomepage = false

    @showScreenShot = ->
      # TODO: move out of controller
      $('.md-homepage-content').animate({scrollTop: $('.md-homepage-intro-bg').offset().top}, 200)

    @loginWithFacebook = ->
      # if has unsaved places
      if TheProject.places.length
        MpUser.login (->
          MpProjects.createProject(TheProject.project).then (project) ->
            $q.all(TheProject.savePlacesOfProject(TheProject.places, project))
            .then ->
              "/project/#{project.id}"
        )
      else
        MpUser.login '/dashboard'
      $scope.interface.showUserSection = false
]
