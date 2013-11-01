app.controller 'OutsideViewCtrl',
['MpUser','MpProjects','$q','$location','MpUI','MapPlaces','MpUserGuide',
class OutsideViewCtrl

  constructor: (MpUser, MpProjects, $q, $location, MpUI, MapPlaces, MpUserGuide) ->
    @hideHomepage = false

    @loginWithFacebook = ->
      # if has unsaved places
      if MapPlaces.length
        MpUser.fbLogin ->
          MpProjects.createProject(MapPlaces.project).then (project) ->

            allPlacesSaved = []
            unsavedPlaces = MapPlaces.map((place) -> place.attributes)

            MapPlaces.reset(null, {silent: true})
            MapPlaces.url = "/api/projects/#{project.id}/places"

            for place in unsavedPlaces
              do (place) ->
                saved = $q.defer()
                MapPlaces.create(place, {success: -> saved.resolve()})
                allPlacesSaved.push(saved)

            $q.all(allPlacesSaved).then ->
              MapPlaces.reset(null, {silent: true})
              $location.path "/project/#{project.id}"
              MpUI.showSideMenu = false
      else
        MpUser.fbLogin ->
          $location.path '/dashboard'
          MpUI.showSideMenu = false


    @initUserGuide = ->
      MpUserGuide.init()
]
