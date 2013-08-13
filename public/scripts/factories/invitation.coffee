# invitations
app.factory 'Invitation', ['$http', ($http) ->

  generate: (project_id)->
    postBody =
      invitation: {project_id: project_id}
    $http.post('/invitation/generate', postBody).then (response) -> response.data.code
]
