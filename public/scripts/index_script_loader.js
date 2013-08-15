// Angular loader
(function(i){'use strict';function d(c,b,e){return c[b]||(c[b]=e())}return d(d(i,"angular",Object),"module",function(){var c={};return function(b,e,f){e&&c.hasOwnProperty(b)&&(c[b]=null);return d(c,b,function(){function a(a,b,d){return function(){c[d||"push"]([a,b,arguments]);return g}}if(!e)throw Error("No module: "+b);var c=[],d=[],h=a("$injector","invoke"),g={_invokeQueue:c,_runBlocks:d,requires:e,name:b,provider:a("$provide","provider"),factory:a("$provide","factory"),service:a("$provide","service"),
value:a("$provide","value"),constant:a("$provide","constant","unshift"),filter:a("$filterProvider","register"),controller:a("$controllerProvider","register"),directive:a("$compileProvider","directive"),config:h,run:function(a){d.push(a);return this}};f&&h(f);return g})}})})(window);

// $script.js
(function(e,t,n){typeof module!="undefined"&&module.exports?module.exports=n():typeof define=="function"&&define.amd?define(n):t[e]=n()})("$script",this,function(){function v(e,t){for(var n=0,r=e.length;n<r;++n)if(!t(e[n]))return f;return 1}function m(e,t){v(e,function(e){return!t(e)})}function g(e,t,a){function d(e){return e.call?e():r[e]}function b(){if(!--p){r[h]=1,c&&c();for(var e in s)v(e.split("|"),d)&&!m(s[e],d)&&(s[e]=[])}}e=e[l]?e:[e];var f=t&&t.call,c=f?t:a,h=f?e.join(""):t,p=e.length;return setTimeout(function(){m(e,function(e){if(e===null)return b();if(u[e])return h&&(i[h]=1),u[e]==2&&b();u[e]=1,h&&(i[h]=1),y(!n.test(e)&&o?o+e+".js":e,b)})},0),g}function y(n,r){var i=e.createElement("script"),s=f;i.onload=i.onerror=i[d]=function(){if(i[h]&&!/^c|loade/.test(i[h])||s)return;i.onload=i[d]=null,s=1,u[n]=2,r()},i.async=1,i.src=n,t.insertBefore(i,t.firstChild)}var e=document,t=e.getElementsByTagName("head")[0],n=/^https?:\/\//,r={},i={},s={},o,u={},a="string",f=!1,l="push",c="DOMContentLoaded",h="readyState",p="addEventListener",d="onreadystatechange";return!e[h]&&e[p]&&(e[p](c,function b(){e.removeEventListener(c,b,f),e[h]="complete"},f),e[h]="loading"),g.get=y,g.order=function(e,t,n){(function r(i){i=e.shift(),e.length?g(i,r):g(i,t,n)})()},g.path=function(e){o=e},g.ready=function(e,t,n){e=e[l]?e:[e];var i=[];return!m(e,function(e){r[e]||i[l](e)})&&v(e,function(e){return r[e]})?t():!function(e){s[e]=s[e]||[],s[e][l](t),n&&n(i)}(e.join("|")),g},g.done=function(e){g([null],e)},g})

// load all of the dependencies asynchronously.
$.ajax('http://www.geoplugin.net/json.gp', {
  dataType: 'jsonp',
  jsonp: 'jsoncallback',
  success: function(data) {
    window.userLocation = {
      latitude: data.geoplugin_latitude,
      longitude: data.geoplugin_longitude
    };
    $script.done('UserLocation');
  }
});

$script('//connect.facebook.net/en_US/all.js', function() {
  appendLoadingProgress('Social module loaded...');
  FB.init({
    appId      : '580227458695144',
    channelUrl : location.origin + '/fb_channel.html',
    status     : true,
    cookie     : true,
    xfbml      : true
  });
  FB.getLoginStatus(function (response) {
    appendLoadingProgress('User identity checked...');
    if (response.status === 'connected') {
      window.user = response.authResponse;
    } else {
      window.user = {};
    }
    $script.done('Facebook');
  });
});

$script([
  '/javascripts/_libraries/lodash.js',
  '/javascripts/_libraries/socket.io.min.js',
  '/javascripts/_libraries/jquery-ui-1.10.3.custom.min.js',
  '/javascripts/_libraries/jquery.easyModal.js',
  '/javascripts/_libraries/masonry.pkgd.min.js',
  '/javascripts/_libraries/bootstrap.min.js',
  '/javascripts/_libraries/perfect-scrollbar-0.4.3.min.js',
  '/javascripts/_libraries/perfect-scrollbar-0.4.3.with-mousewheel.min.js',
  '/javascripts/_libraries/angular.js',
  '/javascripts/_libraries/restangular.js',
  '/javascripts/_modules_for_libraries/angular-easy-modal.js',
  '/javascripts/_modules_for_libraries/angular-masonry.js',
  '/javascripts/_modules_for_libraries/angular-perfect-scrollbar.js',
  '/javascripts/_modules_for_libraries/angular-bootstrap.js',
  '/javascripts/_modules_for_libraries/angular-jquery-ui.js',
  '/javascripts/application/config.js',
  '//maps.googleapis.com/maps/api/js?key=AIzaSyAGJjfEZSf93ey42aqJDIVuOVaLnpUUzWs&libraries=places&sensor=true&callback=initGoogleMaps'
], function() {
  $script([
    '/javascripts/application/run.js',
    '/javascripts/factories/invitation.js',
    '/javascripts/factories/mp-chatbox.js',
    '/javascripts/factories/mp-initializer.js',
    '/javascripts/factories/mp-projects.js',
    '/javascripts/factories/mp-template-cache.js',
    '/javascripts/factories/the-map.js',
    '/javascripts/factories/mp-user.js',
    '/javascripts/keepers/mp-bottom-modalbox.js',
    '/javascripts/keepers/mp-center-user-location.js',
    '/javascripts/keepers/mp-friends-panel.js',
    '/javascripts/keepers/mp-headsup-messager.js',
    '/javascripts/keepers/mp-map-searchbox.js',
    '/javascripts/keepers/mp-user-section-tabs.js',
    '/javascripts/keepers/mp-user-section.js',
    '/javascripts/views/all_projects_view/all-projects-view-ctrl.js',
    '/javascripts/views/all_projects_view/mini-map-cover.js',
    '/javascripts/views/all_projects_view/mp-all-projects-item.js',
    '/javascripts/views/all_projects_view/mp-navbar-bottom.js',
    '/javascripts/views/new_project_view/new-project-view-ctrl.js',
    '/javascripts/views/outside_view/outside-view-ctrl.js',
    '/javascripts/views/project_view/mp-chat-history-item.js',
    '/javascripts/views/project_view/mp-chat-history.js',
    '/javascripts/views/project_view/mp-chatbox-directive.js',
    '/javascripts/views/project_view/mp-chatbox-input.js',
    '/javascripts/views/project_view/project-view-ctrl.js',
    '/javascripts/views/shared/marker-info.js',
    '/javascripts/views/shared/mp-edit-project-form.js',
    '/javascripts/views/shared/mp-map-canvas.js',
    '/javascripts/views/shared/mp-map-drawer.js',
    '/javascripts/views/shared/mp-tabs.js',
    '/javascripts/views/shared/sidebar-place.js'
  ], 'Application', function() {
    appendLoadingProgress('Application layer ready...');
  })
});

$script.ready(['UserLocation', 'Facebook', 'Application'], function() {
  angular.bootstrap(document, ['mapApp']);
});

function appendLoadingProgress(message) {$('#load_progress').append($('<li>').html(message));}
function initGoogleMaps() {appendLoadingProgress('Google Map module loaded...');}
