# declear
app = angular.module('mapApp', [
  'restangular',
  'angular-easy-modal',
  'angular-masonry',
  'angular-perfect-scrollbar',
  'angular-bootstrap',
  'angular-jquery-ui',

  'mp-chatbox-provider'
])


# config
app.config(['MpChatboxProvider', '$httpProvider', '$routeProvider',
'$locationProvider',
(MpChatboxProvider, $httpProvider, $routeProvider, $locationProvider) ->

  # Filters
  # ========================================
  # MpProject
  # ----------------------------------------
  outsideFilter_MpProject = ['MpProjects', (MpProjects) ->

      MpProjects.resetAll()
      return
  ]

  allProjectsFilter_MpProject = ['MpInitializer', 'MpProjects', '$q', '$timeout',
    '$rootScope', '$location',
    (MpInitializer, MpProjects, $q, $timeout, $rootScope, $location) ->

      filter = $q.defer()

      MpInitializer.then ->
        if $rootScope.MpUser.checkLogin()
          MpProjects.getProjects({include_participated: true}).then (projects) ->
            if projects.length == 0
              $location.path('/new_project')
            else
              MpProjects.resetCurrent()
            filter.resolve()
        else
          filter.reject()

      return filter.promise
  ]

  newProjectFilter_MpProject = ['MpInitializer', 'MpProjects', '$q', '$timeout',
    '$rootScope', '$route', 'Restangular',
    (MpInitializer, MpProjects, $q, $timeout, $rootScope,
     $route, Restangular) ->

      filter = $q.defer()

      MpInitializer.then ->
        if $rootScope.MpUser.checkLogin()
          if !MpProjects.projects.route
            loadProjects = MpProjects.getProjects({include_participated: true})
          # from OutsideViewCtrl
          if $route.previous && $route.previous.controller == 'OutsideViewCtrl' && MpProjects.currentProjectPlaces.length > 0
            # have unsaved places
            debugger
            $projects = Restangular.all('projects')
            $projects.post({title: 'last unsaved project'}).then (project) ->
              $places = project.all('places')
              _places = _.map MpProjects.currentProjectPlaces, (place) ->
                $places.post(place)
              $q.all(_places).then (places) ->
                MpProjects.currentProjectPlaces   = places
                MpProjects.__currentProjectPlaces = _.clone(places)
                # --- END ---
                filter.resolve()
              MpProjects.projects.push project
              MpProjects.__projects = _.clone MpProjects.projects
          # not from OutsideViewCtrl || not have unsaved places
          else
            standardProcedure = (projects) ->
              if projects.length == 0
                projects.post({title: 'last unsaved project'}).then (project) ->
                  MpProjects.currentProject = project
                  MpProjects.projects       = [project]
                  MpProjects.__projects     = [project]
                  # --- END ---
                  filter.resolve()
              else
                project = _.find MpProjects.projects, {title: 'last unsaved project'}
                if project
                  MpProjects.currentProject = project
                  project.getList('places').then (places) ->
                    MpProjects.currentProjectPlaces   = places
                    MpProjects.__currentProjectPlaces = _.clone(places)
                    # --- END ---
                    filter.resolve()
                else
                  projects.post({title: 'last unsaved project'}).then (project) ->
                    MpProjects.currentProject = project
                    # --- END ---
                    filter.resolve()
            # --- END of stardardProcedure ---
            if loadProjects then loadProjects.then(standardProcedure) else standardProcedure(MpProjects.projects)
        # user not signed in
        else
          filter.reject()

      return filter.promise
  ]

  projectFilter_MpProject = ['MpInitializer', 'MpProjects', '$q', '$timeout',
    '$rootScope', '$route', 'Restangular', '$location',
    (MpInitializer, MpProjects, $q, $timeout, $rootScope,
     $route, Restangular, $location) ->

      filter = $q.defer()

      MpInitializer.then ->
        if $rootScope.MpUser.checkLogin()
          if !MpProjects.projects.route
            loadProjects = MpProjects.getProjects({include_participated: true})
          standardProcedure = (projects) ->
            project = _.find projects, {id: Number($route.current.params.project_id)}
            # did not find requested project
            if !project
              # make double check on server
              $project = Restangular.one('projects', $route.current.params.project_id)
              $project.get().then(
                ((project) ->
                  MpProjects.getProjects({include_participated: true})
                  MpProjects.currentProject = project
                  project.getList('users').then (users) ->
                    $rootScope.MpChatbox.__participatedUsers = users
                  project.getList('places').then (places) ->
                    MpProjects.currentProjectPlaces   = places
                    MpProjects.__currentProjectPlaces = _.clone(places)
                    # --- END ---
                    filter.resolve()
                ),
                # did not find requested project on server
                (->
                  $location.path('/all_projects')
                  # --- END ---
                  filter.reject()
                )
              )
            # did find requested project
            else
              MpProjects.currentProject = project
              project.getList('users').then (users) ->
                $rootScope.MpChatbox.__participatedUsers = users
              project.getList('places').then (places) ->
                MpProjects.currentProjectPlaces   = places
                MpProjects.__currentProjectPlaces = _.clone(places)
                # --- END ---
                filter.resolve()
          # --- END of stardardProcedure ---
          if loadProjects then loadProjects.then(standardProcedure) else standardProcedure(MpProjects.projects)
        # user not signed in
        else
          filter.reject()

      return filter.promise
  ]

  # MpChatbox
  # ----------------------------------------
  filter_MpChatbox = ['MpInitializer', '$q', '$timeout', '$rootScope',
    '$location', 'MpChatbox',
    (MpInitializer, $q, $timeout, $rootScope, $location, MpChatbox) ->

      filter = $q.defer()

      MpInitializer.then ->
        if $rootScope.MpUser.checkLogin()
          if !MpChatbox.socket.online
            MpChatbox.socket.connect().then ->
              MpChatbox.initialize()
        else
          if MpChatbox.socket.online
            MpChatbox.socket.disconnect()
            MpChatbox.destroy()
        filter.resolve()

      return filter.promise
  ]


  # route
  $routeProvider
  .when('/', {
    controller: 'OutsideViewCtrl'
    templateUrl: '/scripts/views/outside_view/outside-view.html'
    resolve:
      MpInitializer: 'MpInitializer'
      filter:         outsideFilter_MpProject
      filter_MpChatbox: filter_MpChatbox
  })
  .when('/all_projects', {
    controller: 'AllProjectsViewCtrl'
    templateUrl: '/scripts/views/all_projects_view/all-projects-view.html'
    resolve:
      MpInitializer: 'MpInitializer'
      filter:         allProjectsFilter_MpProject
      filter_MpChatbox: filter_MpChatbox
  })
  .when('/new_project', {
    controller: 'NewProjectViewCtrl'
    templateUrl: '/scripts/views/new_project_view/new-project-view.html'
    resolve:
      MpInitializer: 'MpInitializer'
      filter:         newProjectFilter_MpProject
      filter_MpChatbox: filter_MpChatbox
  })
  .when('/project/:project_id', {
    controller: 'ProjectViewCtrl'
    templateUrl: '/scripts/views/project_view/project-view.html'
    resolve:
      MpInitializer: 'MpInitializer'
      filter:         projectFilter_MpProject
      filter_MpChatbox: filter_MpChatbox
  })
  .otherwise({redirectTo: '/'})

  $locationProvider.html5Mode(true)

  # CSRF
  token = angular.element('meta[name="csrf-token"]').attr('content')
  $httpProvider.defaults.headers.common['X-CSRF-Token'] = token

  # google map
  google.maps.visualRefresh = true

  # socket
  MpChatboxProvider.setSocketServer(location.protocol + '//' + location.hostname + ':4000')
])
