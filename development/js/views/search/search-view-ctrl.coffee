app.controller 'SearchViewCtrl',
['$scope', '$location', 'MpFriends', ($scope, $location, MpFriends) ->

  @searchUser = ->
    if @searchInput
      $location.search('name', @searchInput)
      $scope.insideViewCtrl.MpFriends.findUserByName(@searchInput).then (users) =>
        @searchResults = users
        if users.length
          @showNoResults = false
        else
          @lastSearchInput = @searchInput
          @showNoResults = true

  @addUserAsFriend = (user) ->
    MpFriends.addUserAsFriend(user)


  # --- Init ---
  @showNoResults = false

  if $location.search().name
    @searchInput = $location.search().name
    @searchUser()
  else
    @searchResults = []


  return
]
