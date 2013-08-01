#= require libraries/modernizr.min.js
#= require libraries/socket.io.min.js
#= require libraries/jquery.js
#= require libraries/angular.min.js
#= require modules/angular-socket.io.coffee
#= require modules/angular-google.map.coffee
#= require modules/angular-resource.min.js
#= require modules/angular-tp.resources.coffee



# declear
app = angular.module('travel-plan:map',
  ['angular-socket.io', 'angular-google.map', 'angular-tp.resources'])

# config
app.config([
  'socketProvider', 'googleMapProvider', '$httpProvider', '$routeProvider',
  (socketProvider, googleMapProvider, $httpProvider, $routeProvider) ->
    # socket
    socketProvider.setServerUrl('http://local.dev:4000')

    # CSRF
    token = angular.element('meta[name="csrf-token"]').attr('content')
    $httpProvider.defaults.headers.common['X-CSRF-Token'] = token

    # google.map
    # googleMapProvider.setup({
    #   mapOptions:
    #     center: new google.maps.LatLng(-34.397, 150.644)
    #     zoom: 8
    #     mapTypeId: google.maps.MapTypeId.ROADMAP
    #     disableDefaultUI: true
    #   mapElement: angular.element('.tp-map-canvas')[0]
    #   defaultBounds: new google.maps.LatLngBounds(
    #     new google.maps.LatLng(-33.8902, 151.1759),
    #     new google.maps.LatLng(-33.8474, 151.2631)
    #   )
    #   enablePlaceService: true
    #   searchBoxElement: document.getElementById('navbar_searchbox')
    # })

    # route
    $routeProvider
    .when('/')
    .when('/plan/:plan_id/:state')
    .otherwise({redirectTo: '/'})

])

# init
app.run([
  'googleMap', '$rootScope', 'Plan', 'socket', '$route', '$location',
  (googleMap, $rootScope, Plan, socket, $route, $location) ->
    # console.log

    # interface control
    $rootScope.interface = {
      hideIntroOverlay: false
      hidePlanContainer: true
      hideChatPlaceContainer: true
      hideCreatePlanForm: true
      hidePlaceContainer: false
      hideChatContainer: true
      displayBothPlacesAndChat: false

      showCreatePlan: ->
        @hideIntroOverlay = true
        @hidePlanContainer = false
        @hideCreatePlanForm = false

      createPlan: (form, newPlan) ->
        if form.$valid
          plan = Plan.save newPlan, =>
            @hidePlanContainer = true
            @hideChatPlaceContainer = false
            @hideCreatePlanForm = true
            $location.path("/plan/#{plan.id}/places")
            $rootScope.plans.unshift(plan)

      focusSearchbox: -> $('#navbar_searchbox').focus()
    }

    # routes
    $rootScope.$on '$routeChangeSuccess', (event, current, previous) ->
      if current.params.plan_id
        $rootScope.interface.hidePlanContainer = true
        $rootScope.interface.hideChatPlaceContainer = false
        $rootScope.interface.displayBothPlacesAndChat = false
      else
        $rootScope.interface.hidePlanContainer = false
        $rootScope.interface.hideChatPlaceContainer = true
        $rootScope.interface.displayBothPlacesAndChat = false
      switch current.params.state
        when 'places'
          $rootScope.interface.hidePlaceContainer = false
          $rootScope.interface.hideChatContainer = true
          $rootScope.interface.displayBothPlacesAndChat = false
        when 'chat'
          $rootScope.interface.hidePlaceContainer = true
          $rootScope.interface.hideChatContainer = false
          $rootScope.interface.displayBothPlacesAndChat = false
        when 'both'
          $rootScope.interface.hidePlaceContainer = false
          $rootScope.interface.hideChatContainer = false
          $rootScope.interface.displayBothPlacesAndChat = true

    # plans
    $rootScope.plans = Plan.query (plans) -> $rootScope.interface.hidePlanContainer = false if plans.length > 0 && !$route.current.params.plan_id

    # map
    # ----------------------------------------


])

# controller
app.controller 'AppCtrl', [
  '$scope', '$route',
  ($scope, $route) ->
    $scope.$on '$routeChangeStart', (event, future, current) ->
      # console.log event, current, previous
    $scope.$on '$routeChangeSuccess', (event, current, previous) ->
      # console.log event, current, previous
]


app.controller 'ManagePlansCtrl', [
  '$scope', 'Plan',
  ($scope, Plan) ->
]


app.controller 'PlaceChatCtrl', [
  '$scope', 'Plan', '$location', 'socket',
  ($scope, Plan, $location, socket) ->

    loadPlanSuccessful = (plan, getResponseHeaders) ->
      $scope.chatHistory = []
      socket.unsubChannel ->
        socket.subChannel plan.id, newMessageCallback

    loadPlanError = (error) -> $location.path('/')
    newMessageCallback = (data) ->
      json = angular.fromJson(data)
      console.log '--> new sub message', json
      $scope.chatHistory.push json

    # init
    $scope.$on '$routeChangeSuccess', (event, current, previous) ->
      needToLoadPlan = current.params.plan_id && (!previous || (previous.params.plan_id != current.params.plan_id))
      if needToLoadPlan
        $scope.plan = Plan.get(
          { id: current.params.plan_id },
          loadPlanSuccessful,
          loadPlanError)
      else if !current.params.plan_id
        socket.unsubChannel()

    $scope.$on 'pubMessage', (event, messageBody) -> socket.pubChat(messageBody)

    $scope.chatHistory = []
]


# directive
app.directive 'chatbox', ->
  (scope, element, attrs) ->
    element.on 'keypress', (event) ->
      if event.keyCode == 13
        if element.val() != ""
          messageBody = element.val()
          scope.$emit('pubMessage', messageBody)
          element.val('')
        return false


app.directive 'chatHistoryItem', [
  '$compile',
  ($compile) ->
    userBehaviorItem = document.getElementById('user_behavior_item').innerHTML
    messageBubble = document.getElementById('message_bubble').innerHTML

    getTemplate = (type) ->
      switch type
        when 'message' then return messageBubble
        when 'userBehavior' then return userBehaviorItem

    link = (scope, element, attrs) ->
      template = getTemplate(scope.item.type)
      element.append $compile(template)(scope)

    link: link
]

