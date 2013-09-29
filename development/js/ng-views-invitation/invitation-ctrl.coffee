app.controller 'InvitationCtrl',
['$scope', '$location', '$http', 'MpUser', class InvitationCtrl
  constructor: ($scope, $location, $http, MpUser) ->

    @registerUser = (userData) ->
      MpUser.emailRegister userData, ->
        code = /^(.+invitations\/)(.+)$/.exec(location.href)[2]
        $http.get("/api/invitations/#{code}/accept_invitation").then ->
          location.href = '/dashboard'
]
