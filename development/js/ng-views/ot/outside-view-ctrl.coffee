app.controller 'OutsideViewCtrl',
['$scope', 'MpUser', 'TheProject', 'MpProjects', '$q', '$location', class OutsideViewCtrl

  constructor: ($scope, MpUser, TheProject, MpProjects, $q, $location) ->
    @hideHomepage = false

    @loginWithFacebook = ->
      # if has unsaved places
      if TheProject.places.length
        MpUser.fbLogin ->
          MpProjects.createProject(TheProject.project).then (project) ->
            $q.all(TheProject.savePlacesOfProject(TheProject.places, project)).then ->
              $location.path "/project/#{project.id}"
              $scope.interface.showUserSection = false
      else
        MpUser.fbLogin ->
          $location.path '/dashboard'
          $scope.interface.showUserSection = false
]
