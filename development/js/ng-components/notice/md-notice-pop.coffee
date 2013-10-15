app.directive 'mdNoticePop',
['MpUI', (MpUI) ->

  controllerAs: 'MdNoticePopCtrl'
  controller: ['$scope','Backbone','MpNotices','$timeout', class MdNoticePopCtrl

    constructor: ($scope, Backbone, MpNotices, $timeout) ->

      # --- Collection ---
      Notices = Backbone.Collection.extend {
        initialize: ->
          @on 'add', (model) =>
            $timeout ( => @remove(model) ), 3000
      }

      @notices = new Notices


      # --- Callbacks ---
      showNotice = (notices) =>
        @notices.add(notices)


      # --- Init ---
      if MpNotices.initializing
        MpNotices.once 'sync', ->
          showNotice(MpNotices.models)
      else
        showNotice(MpNotices.models)


      # --- Listeners ---
      MpNotices.on 'add', (model) =>
        showNotice([model])
  ]
  link: (scope, element, attrs, MdNoticePopCtrl) ->

    element.on 'click', 'li', ->
      scope.$apply ->
        MpUI.showSideMenu = true
        MdNoticePopCtrl.notices.reset()
]
