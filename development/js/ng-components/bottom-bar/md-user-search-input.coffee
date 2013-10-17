app.directive 'mdUserSearchInput', [->

  controllerAs: 'MdUserSearchInputCtrl'
  controller: ['MpUserSearch', '$location', 'MpUI', class MdUserSearchInputCtrl

    constructor: (MpUserSearch, $location, MpUI) ->

      @searchUser = ($event) ->
        if $event.keyCode == 13 && @searchInput
          MpUI.showSearchIntro = false
          $location.search('name', @searchInput)
          MpUserSearch.searchUserByName(@searchInput)


      @cleanSearchResults = ->
        @searchInput = ''
        $location.search({})
        MpUI.showSearchIntro = true
        MpUserSearch.reset()


      # --- Init ---
      queryParams = $location.search()
      if queryParams.name == true || queryParams.name == ''
        $location.search({})


      if $location.search().name?
        MpUI.showSearchIntro = false
        @searchInput = $location.search().name
        MpUserSearch.searchUserByName(@searchInput)
      else
        @searchInput = ''
  ]

  link: (scope, element, attrs, MdUserSearchInputCtrl) ->
]
