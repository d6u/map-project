// --- Config ---
require.config({
  enforceDefine: true,
  waitSeconds: 5,
  baseUrl: '/assets',
  paths: paths, // paths is defined in index.html.erb file
  map: {},
  shim: {
    'modernizr': {exports: 'Modernizr'},
    'google.maps': {exports: 'google.maps'},
    'facebook': {
      exports: 'FB',
      init: function() {
        this.FB.init({
          appId      : fbAppId,
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
// create deferred object for ip location
define('ipLocationChecked', ['jquery'], function($) {
  this.ipLocationChecked = $.Deferred();
  return this.ipLocationChecked;
});

define('facebookLoginChecked', ['jquery'], function($) {
  this.facebookLoginChecked = $.Deferred();
  return this.facebookLoginChecked;
});

// Progress bar on top
require(['nprogress'], function(NProgress) {
  this.NProgress = NProgress;
  NProgress.start();
});

// facebook login check
require(['facebookLoginChecked', 'facebook'], function(deferred, FB) {
  FB.getLoginStatus(function(response) {
    deferred.resolve(response);
  });
});

// resolve location from ip address
require(['ipLocationChecked', 'ipLocation'], function(deferred, ipLocation) {
  deferred.resolve(ipLocation);
});

// init, bootstrap angularjs
define(['nprogress', 'ipLocationChecked', 'application', 'modernizr', 'google.maps'], function(NProgress) {
  NProgress.inc();
  angular.bootstrap(document, ['mapApp']);
});
