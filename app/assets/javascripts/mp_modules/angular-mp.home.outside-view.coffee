app = angular.module 'angular-mp.home.outside-view', []


app.controller 'OutsideViewCtrl',['MpProjects', 'TheMap',
(MpProjects, TheMap) ->

  MpProjects.reset()
  TheMap.reset()
]
