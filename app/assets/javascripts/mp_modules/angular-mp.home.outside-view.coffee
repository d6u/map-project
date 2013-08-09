app = angular.module 'angular-mp.home.outside-view', []


app.controller 'OutsideViewCtrl',['ActiveProject', 'TheMap',
(ActiveProject, TheMap) ->

  ActiveProject.reset()
  TheMap.reset()
]
