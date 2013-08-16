define ['angular'], ->

  # declear
  window.app = angular.module('mapApp', [
    'ngAnimate',
    'ngRoute',
    'route-segment',
    'view-segment',

    'restangular',
    'angular-masonry',
    'angular-perfect-scrollbar',
    'angular-bootstrap',
    'angular-jquery-ui',

    'mp-chatbox-provider'
  ])


  # config
  app.config(['MpChatboxProvider', '$httpProvider', '$routeSegmentProvider',
  '$locationProvider', '$routeProvider',
  (MpChatboxProvider, $httpProvider, $routeSegmentProvider, $locationProvider,
   $routeProvider) ->

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
    $routeSegmentProvider.options.autoLoadTemplates = true

    $routeSegmentProvider
      .when('/',                         'ot')
      .when('/home',                     'in.allProjects')
      .when('/home/project/:project_id', 'in.project')

      .segment('ot', {
        templateUrl: '/scripts/views/outside-view/outside-view.html'
        controller:  'OutsideViewCtrl'
        resolve:
          MpInitializer:    'MpInitializer'
          filter:           outsideFilter_MpProject
          filter_MpChatbox: filter_MpChatbox
        })

      .segment('in', {
        templateUrl: '/scripts/views/inside-view/inside-view.html'
        controller: 'InsideViewCtrl'
        resolve:
          MpInitializer:    'MpInitializer'
          filter_MpChatbox: filter_MpChatbox
        })

      .within()
        .segment('allProjects', {
          templateUrl: '/scripts/views/all-projects-view/all-projects-view.html'
          controller: 'AllProjectsViewCtrl'
          resolve:
            filter: allProjectsFilter_MpProject
          })
        .segment('project', {
          templateUrl: '/scripts/views/project-view/project-view.html'
          controller: 'ProjectViewCtrl'
          resolve:
            filter: projectFilter_MpProject
          })

      # .segment('in', {
      #   templateUrl: '/scripts/views/inside-view/inside-view.html'
      #   controller: 'InsideViewCtrl'
      #   })

    # .when('/', {
    #   controller: 'OutsideViewCtrl'
    #   templateUrl: '/scripts/views/outside_view/outside-view.html'
    #   resolve:

    # })
    # .when('/all_projects', {
    #   controller: 'AllProjectsViewCtrl'
    #   templateUrl: '/scripts/views/all-projects-view/all-projects-view.html'
    #   resolve:
    #     MpInitializer: 'MpInitializer'
    #     filter:         allProjectsFilter_MpProject
    #     filter_MpChatbox: filter_MpChatbox
    # })
    # .when('/new_project', {
    #   controller: 'NewProjectViewCtrl'
    #   templateUrl: '/scripts/views/new_project-view/new-project-view.html'
    #   resolve:
    #     MpInitializer: 'MpInitializer'
    #     filter:         newProjectFilter_MpProject
    #     filter_MpChatbox: filter_MpChatbox
    # })
    # .when('/project/:project_id', {
    #   controller: 'ProjectViewCtrl'
    #   templateUrl: '/scripts/views/project-view/project-view.html'
    #   resolve:
    #     MpInitializer: 'MpInitializer'
    #     filter:         projectFilter_MpProject
    #     filter_MpChatbox: filter_MpChatbox
    # })
    $routeProvider.otherwise({redirectTo: '/'})

    $locationProvider.html5Mode(true)

    # CSRF
    token = angular.element('meta[name="csrf-token"]').attr('content')
    $httpProvider.defaults.headers.common['X-CSRF-Token'] = token

    # google map
    google.maps.visualRefresh = true

    # socket
    MpChatboxProvider.setSocketServer(location.protocol + '//' + location.hostname + ':4000')
  ])
