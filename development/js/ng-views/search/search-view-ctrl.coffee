app.controller 'SearchViewCtrl',
['$scope', '$location', 'MpUserSearch', class SearchViewCtrl

  constructor: ($scope, $location, MpUserSearch) ->

    @showNoResults = false

    $scope.$watch (->
      return MpUserSearch.models
    ), =>
      @searchResults = MpUserSearch.models
      if MpUserSearch.length
        @showNoResults = false
      else
        @showNoResults = true
        @lastSearchInput = $location.search().name


    @addUserAsFriend = (user) ->
      MpFriends.addUserAsFriend(user)
]
