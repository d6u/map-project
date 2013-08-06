app = angular.module 'angular-mp.home.project-view', []


app.controller 'ProjectViewCtrl',
['$scope', 'Project', '$location', '$rootScope', '$q', '$timeout',
 '$templateCache', '$compile', '$route',
($scope, Project, $location, $rootScope, $q, $timeout,
 $templateCache, $compile, $route) ->

  # callbacks
  loadPlaceOntoMap = (place) ->
    coordMatch = /\((.+), (.+)\)/.exec place.coord
    latLog = new google.maps.LatLng coordMatch[1], coordMatch[2]
    markerOptions =
      map: $scope.googleMap.map
      title: place.name
      position: latLog
      icon:
        url: "/assets/number_#{place.order}.png"

    place.$$marker = new google.maps.Marker markerOptions


  savePlace = (place) ->
    place.id = null
    places = $scope.currentProject.project.all('places')
    places.post(place).then (newPlace) ->
      angular.extend place, newPlace

  # init
  if $scope.user.fb_access_token
    # login with unsaved places
    Project.customGET($route.current.params.project_id).then (project) ->
      $scope.currentProject.project = project
      project.all('places').getList().then (places) ->
        $scope.currentProject.places = places
        $scope.googleMap.mapReady.promise.then ->
          loadPlaceOntoMap place for place in $scope.currentProject.places

  # events
  $scope.$on 'placeAddedToList', (event, place) ->
    savePlace(place)

  $scope.$on 'placeRemovedFromList', (event, place) ->
    place.$$marker = null
    place.remove()

  $scope.$on 'projectUpdated', (event, project) ->
    $scope.currentProject.project = project
]


# ChatBoxCtrl
app.controller 'ChatBoxCtrl',
['$scope', 'Friendship', 'Invitation',
($scope, Friendship, Invitation) ->

  $scope.addFriendsToProject = ->
    $scope.friendships = []
    Friendship.getList().then (friendships)->
      $scope.friendships = friendships
    $scope.$broadcast 'showAddFriendsModal'

  $scope.getInvitationCode = ->
    Invitation.generate($scope.currentProject.project.id).then (code) ->
      $scope.invitationCode = location.origin + '/invitation/join/' + code

  $scope.invite = ->

]
