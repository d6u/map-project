# mp-all-projects-item
app.directive 'mpAllProjectsItem', [->
  (scope, element, attrs) ->

    if scope.project.owner_id != scope.MpUser.$$user.id
      scope.projectMessage = 'This is a group project'
]
