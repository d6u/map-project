angular.module('angular-tp.resources', ['ngResource'])

.factory('Plan', [
  '$resource',
  ($resource) ->
    $resource('/plans/:id', {id: '@id'})
])
