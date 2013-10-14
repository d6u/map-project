app.directive 'mdUserSearchInput', [->

  controllerAs: 'MdUserSearchInputCtrl'
  controller: ['MpUserSearch', '$location', class MdUserSearchInputCtrl

    constructor: (MpUserSearch, $location) ->

      @searchUser  = ($event) ->
        if $event.keyCode == 13 && @searchInput
          $location.search('name', @searchInput)
          MpUserSearch.searchUserByName(@searchInput)


      # --- Init ---
      queryParams = $location.search()
      if queryParams.name == true || queryParams.name == ''
        $location.search({})


      if $location.search().name?
        @searchInput = $location.search().name
        MpUserSearch.searchUserByName(@searchInput)
      else
        @searchInput = ''
  ]

  link: (scope, element, attrs, MdUserSearchInputCtrl) ->
]
