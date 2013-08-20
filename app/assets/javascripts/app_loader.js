// RequireJS
// -- Config --
// `.js` will be automatically append to file urls
require.config({
  paths: {
    // Utility libraries
    'jquery':                   '_libraries/jquery-2.0.3',
    'bootstrap':                '_libraries/bootstrap.min',
    'jquery.ui':                '_libraries/jquery-ui-1.10.3.custom.min',
    'jquery.perfect-scrollbar': '_libraries/perfect-scrollbar-0.4.3.with-mousewheel.min',
    'lodash':    '_libraries/lodash-1.3.1',
    'modernizr': '_libraries/modernizr.min',
    'socket.io': '_libraries/socket.io.min',
    // Masonry
    'eventie':            '/bower_components/eventie',
    'doc-ready':          '/bower_components/doc-ready',
    'eventEmitter':       '/bower_components/eventEmitter',
    'get-style-property': '/bower_components/get-style-property',
    'get-size':           '/bower_components/get-size',
    'matches-selector':   '/bower_components/matches-selector',
    'outlayer':           '/bower_components/outlayer',
    'masonry':            '/bower_components/masonry/masonry',
    // Angular.js
    'minErr':                '_libraries/minErr',
    'angular.loader':        '_libraries/angular-loader-1.2.0rc1',
    'angular':               '_libraries/angular-1.2.0rc1',
    'angular.animate':       '_libraries/angular-animate-1.2.0rc1',
    'angular.route':         '_libraries/angular-route-1.2.0rc1',
    'angular.route.segment': '_libraries/angular-route-segment-1.0.3',
    'angular.restangular':   '_libraries/restangular-1.1.3',
    // 3rd parties
    'facebook':          '//connect.facebook.net/en_US/all',
    'google.maps':       '//maps.googleapis.com/maps/api/js?key=AIzaSyAGJjfEZSf93ey42aqJDIVuOVaLnpUUzWs&libraries=places&sensor=true&callback=initGoogleMaps',
    'ip_to_geolocation': 'http://www.geoplugin.net/json.gp?jsoncallback=define'
  },
  shim: {
    'bootstrap':                ['jquery'],
    'jquery.ui':                ['jquery'],
    'jquery.perfect-scrollbar': ['jquery'],
    'google.maps':              ['jquery'],
    'angular':               ['angular.loader', 'jquery'],
    'angular.animate':       ['angular'],
    'angular.route':         ['angular'],
    'angular.route.segment': ['angular', 'angular.route'],
    'angular.restangular':   ['angular', 'lodash'],
    'application/config':    ['google.maps', 'socket.io', 'angular.animate',
                              'angular.route.segment', 'angular.restangular'],

    '_modules_for_libraries/angular-bootstrap':         ['bootstrap'],
    '_modules_for_libraries/angular-jquery-ui':         ['jquery.ui'],
    '_modules_for_libraries/angular-masonry':           ['masonry'],
    '_modules_for_libraries/angular-perfect-scrollbar': ['jquery.perfect-scrollbar']
  }
});

// -- Load --
// Wait for FB the resolve
require(['jquery'], function() {
  window.fbLoginChecked = $.Deferred()
})

require(['jquery', 'facebook'], function() {
  appendLoadingProgress('Social module loaded...');
  FB.init({
    appId      : '580227458695144',
    channelUrl : location.origin + '/fb_channel.html',
    status     : true,
    cookie     : true,
    xfbml      : true
  });
  FB.getLoginStatus(function (response) {
    appendLoadingProgress('User identity certification checked...');
    if (response.status === 'connected') {
      window.user = response.authResponse;
    } else {
      window.user = {};
    }
    window.fbLoginChecked.resolve()
  });
})

require(['ip_to_geolocation'], function(data) {
  window.userLocation = {
    latitude: data.geoplugin_latitude,
    longitude: data.geoplugin_longitude
  };
})

require(['app'])

// -- Helpers --
function appendLoadingProgress(message) {
  $('#load_progress').append($('<li>').html(message));}

function initGoogleMaps() {
  appendLoadingProgress('Google Map module loaded...');}
