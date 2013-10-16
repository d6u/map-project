app.controller 'OutsideViewCtrl',
['MpUser','MpProjects','$q','$location','MpUI','MapPlaces','MpUserGuide',
class OutsideViewCtrl

  constructor: (MpUser, MpProjects, $q, $location, MpUI, MapPlaces, MpUserGuide) ->
    @hideHomepage = false

    @loginWithFacebook = ->
      # if has unsaved places
      if MapPlaces.length
        MpUser.fbLogin ->
          MpProjects.createProject(TheProject.project).then (project) ->
            $q.all(TheProject.savePlacesOfProject(TheProject.places, project)).then ->
              $location.path "/project/#{project.id}"
              MpUI.showSideMenu = false
      else
        MpUser.fbLogin ->
          $location.path '/dashboard'
          MpUI.showSideMenu = false


    @initUserGuide = ->
      MpUserGuide.init()
]
