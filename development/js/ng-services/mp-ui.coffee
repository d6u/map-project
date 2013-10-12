###
MpUI.showSideMenu
MpUI.showHomepage
MpUI.showMapDrawer
MpUI.mapDrawerActiveSection
###


app.factory 'MpUI', [->
  return {
    showSideMenu:  false
    showHomepage:  true
    showMapDrawer: false
    mapDrawerActiveSection: 'searchResults'
    showChatboxBody: false

    showProjectModal: false
    projectModalContent: 'editDetail'
  }
]
