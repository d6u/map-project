# declear
app = angular.module('invitationApp', [
  # 3rd party modules
  'ngAnimate'
  'restangular'

  # Self made modules
  'md-collapse'

  # Application modules that have to run before `.config`
  # empty
])


# config
app.config(['$httpProvider', 'RestangularProvider',
($httpProvider, RestangularProvider) ->


  # CSRF
  # ----------------------------------------
  token = angular.element('meta[name="csrf-token"]').attr('content')
  $httpProvider.defaults.headers.common['X-CSRF-Token'] = token


  # Google Maps
  # ----------------------------------------
  google.maps.visualRefresh = true


  # --- Restangular ---
  convertTimestampToUnix = (element) ->
    if element.created_at
      element.created_at = (new Date).setISO8601(element.created_at)
    if element.updated_at
      element.updated_at = (new Date).setISO8601(element.updated_at)

  RestangularProvider.setBaseUrl('/api')
  RestangularProvider.setResponseInterceptor (data) ->
    if data.length
      for element in data
        convertTimestampToUnix(element)
    else
      convertTimestampToUnix(data)
    return data
])
