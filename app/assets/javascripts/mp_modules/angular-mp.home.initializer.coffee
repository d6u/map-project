app = angular.module 'angular-mp.home.initializer', []


app.factory 'userLocation', ['$http',
($http) ->

  $http.jsonp('http://www.geoplugin.net/json.gp?jsoncallback=JSON_CALLBACK')
  .then (response) ->
    # get user location according to ip
    latitude: response.data.geoplugin_latitude
    longitude: response.data.geoplugin_longitude
]
