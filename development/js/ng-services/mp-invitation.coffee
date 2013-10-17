app.factory 'MpInvitation', ['Restangular', (Restangular) ->

  $invitations = Restangular.all 'invitations'

  MpInvitation = {
    getInvitations: ->
      $invitations.getList()

    generateInvitation: (invitationObj) ->
      $invitations.post(invitationObj)
  }

  return MpInvitation
]
