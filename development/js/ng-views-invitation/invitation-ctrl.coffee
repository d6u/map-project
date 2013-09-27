app.controller 'InvitationCtrl',
['$scope', '$location', '$http', class InvitationCtrl
  constructor: ($scope, $location, $http) ->

    @registerSuccess = (user) ->
      code = /^(.+invitations\/)(.+)$/.exec(location.href)[2]
      $http.get("/api/invitations/#{code}/accept_invitation").then ->
        location.href = '/dashboard'
]
