App.controller('paymentDialogController', ['$scope', 'Dialog', function($scope, Dialog) {
  $scope.subscribe = function() {
    event.preventDefault();

    // do some Stripe stuff

    Dialog.close('paymentDialog', 'woohoo');
  };
}]);
