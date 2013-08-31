# run
app.run(['$rootScope', '$route',
($rootScope, $route) ->

  # Values used to assign classes
  $rootScope.interface = {
    showUserSection: false
    centerSearchBar: true
  }
])
