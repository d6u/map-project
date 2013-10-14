app.controller 'OutsideViewCtrl',
['$scope','MpUser','MpProjects','$q','$location','MpUI'
class OutsideViewCtrl

  constructor: ($scope, MpUser, MpProjects, $q, $location, MpUI) ->
    @hideHomepage = false

    @loginWithFacebook = ->
      # if has unsaved places
      if TheProject.places.length
        MpUser.fbLogin ->
          MpProjects.createProject(TheProject.project).then (project) ->
            $q.all(TheProject.savePlacesOfProject(TheProject.places, project)).then ->
              $location.path "/project/#{project.id}"
              MpUI.showSideMenu = false
      else
        MpUser.fbLogin ->
          $location.path '/dashboard'
          MpUI.showSideMenu = false
]
