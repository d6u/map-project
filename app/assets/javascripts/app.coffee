dependencies = [
  '_modules_for_libraries/angular-bootstrap'
  '_modules_for_libraries/angular-jquery-ui'
  '_modules_for_libraries/angular-masonry'
  '_modules_for_libraries/angular-perfect-scrollbar'

  'application/run'

  'factories/invitation',
  'factories/mp-chatbox',
  'factories/mp-initializer',
  'factories/mp-projects',
  'factories/mp-template-cache',
  'factories/mp-user',
  'factories/the-map',

  'keepers/mp-bottom-modalbox',
  'keepers/mp-center-user-location',
  'keepers/mp-friends-panel',
  'keepers/mp-headsup-messager',
  'keepers/mp-user-section-tabs',
  'keepers/mp-user-section',

  'views/all_projects_view/all-projects-view-ctrl'
  'views/all_projects_view/mini-map-cover'
  'views/all_projects_view/mp-all-projects-item'
  'views/all_projects_view/mp-navbar-bottom'

  'views/new_project_view/new-project-view-ctrl'

  'views/outside_view/outside-view-ctrl'

  'views/project_view/mp-chat-history-item'
  'views/project_view/mp-chat-history'
  'views/project_view/mp-chatbox-directive'
  'views/project_view/mp-chatbox-input'
  'views/project_view/mp-project-add-friends-modal'
  'views/project_view/project-view-ctrl'

  'views/shared/marker-info'
  'views/shared/mp-edit-project-form'
  'views/shared/mp-map-canvas'
  'views/shared/mp-map-drawer'
  'views/shared/mp-map-searchbox'
  'views/shared/mp-tabs'
  'views/shared/sidebar-place'
]

define ['masonry', 'application/config'], (Masonry) ->
  window.Masonry = Masonry
  require dependencies, ->
    appendLoadingProgress('Application layer ready...')
    angular.bootstrap(document, ['mapApp'])
