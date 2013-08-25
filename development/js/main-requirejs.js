// --- Config ---
require.config({
  enforceDefine: true,
  waitSeconds: 5,
  baseUrl: '/assets',
  paths: paths, // paths is defined in index_async.html.erb file
  map: {},
  shim: {
    'modernizr': {exports: 'Modernizr'},
    'google.maps': {exports: 'google.maps'},
    'facebook': {
      exports: 'FB',
      init: function() {
        this.FB.init({
          appId      : '153060941567545',
          channelUrl : location.origin + '/fb_channel.html',
          status     : true,
          cookie     : true,
          xfbml      : true
        });
        return this.FB
      }
    },
    'application': {
      deps: ['jquery'],
      exports: ''
    }
  }
})


// --- 3rd party libraries preparation ---
// function to for async load google map, doesn't do anything else
function initGoogleMaps() {}


// --- Require ---
// create deferred object for facebook login check and ip location
define('appPrepare', ['jquery'], function($) {
  this.appPrepare = {
    facebookLoginCheck: $.Deferred(),
    ipLocationCheck:    $.Deferred()
  }
  return this.appPrepare
})

// facebook login check
require(['appPrepare', 'facebook'], function(appPrepare, FB) {
  FB.getLoginStatus(function(response) {
    appPrepare.facebookLoginCheck.resolve(response)
  })
})

// resolve location from ip address
require(['appPrepare', 'ipLocation'], function(appPrepare, ipLocation) {
  appPrepare.ipLocationCheck.resolve(ipLocation)
})

// init, bootstrap angularjs
define(['appPrepare', 'application', 'facebook', 'modernizr', 'google.maps'], function(appPrepare) {
  angular.bootstrap(document, ['mapApp']);
})
