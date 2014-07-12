App.factory('Subscription', ['$resource', function($resource) {
  $resource('/repos/:repo_id/subscription');
}]);
