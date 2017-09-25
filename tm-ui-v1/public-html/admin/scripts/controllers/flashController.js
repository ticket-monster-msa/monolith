'use strict';

angular.module('ticketmonster').controller('FlashController', ['$scope','flash', function ($scope, flash) {
    $scope.flash = flash;
    $scope.showAlert = false;

    $scope.$watch('flash.getMessage()', function(newVal) {
        var message = newVal;
        if(message && message.text) {
            $scope.showAlert = message.text.length > 0;
        } else {
            $scope.showAlert = false;
        }
    });

    $scope.hideAlert = function() {
        $scope.showAlert = false;
    }
}]);
