

angular.module('ticketmonster').controller('EditMediaItemController', function($scope, $routeParams, $location, flash, MediaItemResource ) {
    var self = this;
    $scope.disabled = false;
    $scope.$location = $location;
    
    $scope.get = function() {
        var successCallback = function(data){
            self.original = data;
            $scope.mediaItem = new MediaItemResource(self.original);
        };
        var errorCallback = function() {
            flash.setMessage({'type': 'error', 'text': 'The mediaItem could not be found.'});
            $location.path("/MediaItems");
        };
        MediaItemResource.get({MediaItemId:$routeParams.MediaItemId}, successCallback, errorCallback);
    };

    $scope.isClean = function() {
        return angular.equals(self.original, $scope.mediaItem);
    };

    $scope.save = function() {
        var successCallback = function(){
            flash.setMessage({'type':'success','text':'The mediaItem was updated successfully.'}, true);
            $scope.get();
        };
        var errorCallback = function(response) {
            if(response && response.data && response.data.message) {
                flash.setMessage({'type': 'error', 'text': response.data.message}, true);
            } else {
                flash.setMessage({'type': 'error', 'text': 'Something broke. Retry, or cancel and start afresh.'}, true);
            }
        };
        $scope.mediaItem.$update(successCallback, errorCallback);
    };

    $scope.cancel = function() {
        $location.path("/MediaItems");
    };

    $scope.remove = function() {
        var successCallback = function() {
            flash.setMessage({'type': 'error', 'text': 'The mediaItem was deleted.'});
            $location.path("/MediaItems");
        };
        var errorCallback = function(response) {
            if(response && response.data && response.data.message) {
                flash.setMessage({'type': 'error', 'text': response.data.message}, true);
            } else {
                flash.setMessage({'type': 'error', 'text': 'Something broke. Retry, or cancel and start afresh.'}, true);
            }
        }; 
        $scope.mediaItem.$remove(successCallback, errorCallback);
    };
    
    $scope.mediaTypeList = [
        "IMAGE"  
    ];
    
    $scope.get();
});