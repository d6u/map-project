app.controller 'SearchViewCtrl',
['$scope', '$location', 'MpUserSearch', class SearchViewCtrl

  constructor: ($scope, $location, MpUserSearch) ->

    $scope.$watch (->
      return MpUserSearch.models
    ), =>
      @searchResults = MpUserSearch.models
      if !MpUserSearch.length
        @lastSearchInput = $location.search().name
]
