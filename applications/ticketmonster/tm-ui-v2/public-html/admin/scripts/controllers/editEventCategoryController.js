

angular.module('ticketmonster').controller('EditEventCategoryController', function($scope, $routeParams, $location, flash, EventCategoryResource ) {
    var self = this;
    $scope.disabled = false;
    $scope.$location = $location;
    
    $scope.get = function() {
        var successCallback = function(data){
            self.original = data;
            $scope.eventCategory = new EventCategoryResource(self.original);
        };
        var errorCallback = function() {
            flash.setMessage({'type': 'error', 'text': 'The eventCategory could not be found.'});
            $location.path("/EventCategories");
        };
        EventCategoryResource.get({EventCategoryId:$routeParams.EventCategoryId}, successCallback, errorCallback);
    };

    $scope.isClean = function() {
        return angular.equals(self.original, $scope.eventCategory);
    };

    $scope.save = function() {
        var successCallback = function(){
            flash.setMessage({'type':'success','text':'The eventCategory was updated successfully.'}, true);
            $scope.get();
        };
        var errorCallback = function(response) {
            if(response && response.data && response.data.message) {
                flash.setMessage({'type': 'error', 'text': response.data.message}, true);
            } else {
                flash.setMessage({'type': 'error', 'text': 'Something broke. Retry, or cancel and start afresh.'}, true);
            }
        };
        $scope.eventCategory.$update(successCallback, errorCallback);
    };

    $scope.cancel = function() {
        $location.path("/EventCategories");
    };

    $scope.remove = function() {
        var successCallback = function() {
            flash.setMessage({'type': 'error', 'text': 'The eventCategory was deleted.'});
            $location.path("/EventCategories");
        };
        var errorCallback = function(response) {
            if(response && response.data && response.data.message) {
                flash.setMessage({'type': 'error', 'text': response.data.message}, true);
            } else {
                flash.setMessage({'type': 'error', 'text': 'Something broke. Retry, or cancel and start afresh.'}, true);
            }
        }; 
        $scope.eventCategory.$remove(successCallback, errorCallback);
    };
    
    
    $scope.get();
});