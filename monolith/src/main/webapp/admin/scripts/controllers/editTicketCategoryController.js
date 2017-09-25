

angular.module('ticketmonster').controller('EditTicketCategoryController', function($scope, $routeParams, $location, flash, TicketCategoryResource ) {
    var self = this;
    $scope.disabled = false;
    $scope.$location = $location;
    
    $scope.get = function() {
        var successCallback = function(data){
            self.original = data;
            $scope.ticketCategory = new TicketCategoryResource(self.original);
        };
        var errorCallback = function() {
            flash.setMessage({'type': 'error', 'text': 'The ticketCategory could not be found.'});
            $location.path("/TicketCategories");
        };
        TicketCategoryResource.get({TicketCategoryId:$routeParams.TicketCategoryId}, successCallback, errorCallback);
    };

    $scope.isClean = function() {
        return angular.equals(self.original, $scope.ticketCategory);
    };

    $scope.save = function() {
        var successCallback = function(){
            flash.setMessage({'type':'success','text':'The ticketCategory was updated successfully.'}, true);
            $scope.get();
        };
        var errorCallback = function(response) {
            if(response && response.data && response.data.message) {
                flash.setMessage({'type': 'error', 'text': response.data.message}, true);
            } else {
                flash.setMessage({'type': 'error', 'text': 'Something broke. Retry, or cancel and start afresh.'}, true);
            }
        };
        $scope.ticketCategory.$update(successCallback, errorCallback);
    };

    $scope.cancel = function() {
        $location.path("/TicketCategories");
    };

    $scope.remove = function() {
        var successCallback = function() {
            flash.setMessage({'type': 'error', 'text': 'The ticketCategory was deleted.'});
            $location.path("/TicketCategories");
        };
        var errorCallback = function(response) {
            if(response && response.data && response.data.message) {
                flash.setMessage({'type': 'error', 'text': response.data.message}, true);
            } else {
                flash.setMessage({'type': 'error', 'text': 'Something broke. Retry, or cancel and start afresh.'}, true);
            }
        }; 
        $scope.ticketCategory.$remove(successCallback, errorCallback);
    };
    
    
    $scope.get();
});