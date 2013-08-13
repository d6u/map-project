app.controller 'NewProjectViewCtrl',
['$scope', '$location', '$rootScope', '$q', '$timeout',
 '$templateCache', '$compile', 'User', 'TheMap',
($scope, $location, $rootScope, $q, $timeout,
 $templateCache, $compile, User, TheMap) ->

  if !User.checkLogin() then return

  # events
  $scope.$on 'placeAddedToList', (event, place) ->
    savePlace(place)

  $scope.$on 'placeRemovedFromList', (event, place) ->
    place.$$marker = null
    place.remove()

  $scope.$on 'projectUpdated', ->
    $location.path('/project/' + ActiveProject.project.id)

  $scope.$on 'projectRemoved', (event, project_id) ->
    ActiveProject.project.remove()
    $location.path('/all_projects')
]