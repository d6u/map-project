# mp-all-projects-item
app.directive 'mpAllProjectsItem', [->
  (scope, element, attrs) ->

    if scope.project.owner_id != scope.User.$$user.id
      scope.projectMessage = 'This is a group project'
]
