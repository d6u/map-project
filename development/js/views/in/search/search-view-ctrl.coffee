app.controller 'SearchViewCtrl',
['$scope', '$location', ($scope, $location) ->

  @searchUser = ->
    if @searchInput
      $location.search('name', @searchInput)
      $scope.insideViewCtrl.mpFriends.findUserByName(@searchInput).then (users) =>
        @searchResults = users
        if users.length
          @showNoResults = false
        else
          @lastSearchInput = @searchInput
          @showNoResults = true

  @addUserAsFriend = (user) ->
    user.addFriend()
    # TODO: send notification


  # --- Init ---
  @showNoResults = false

  if $location.search().name
    @searchInput = $location.search().name
    @searchUser()
  else
    @searchResults = []


  return
]
