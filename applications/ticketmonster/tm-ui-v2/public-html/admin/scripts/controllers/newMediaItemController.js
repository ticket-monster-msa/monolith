
angular.module('ticketmonster').controller('NewMediaItemController', function ($scope, $location, locationParser, flash, MediaItemResource ) {
    $scope.disabled = false;
    $scope.$location = $location;
    $scope.mediaItem = $scope.mediaItem || {};
    
    $scope.mediaTypeList = [
        "IMAGE"
    ];
    

    $scope.save = function() {
        var successCallback = function(data,responseHeaders){
            var id = locationParser(responseHeaders);
            flash.setMessage({'type':'success','text':'The mediaItem was created successfully.'});
            $location.path('/MediaItems');
        };
        var errorCallback = function(response) {
            if(response && response.data && response.data.message) {
                flash.setMessage({'type': 'error', 'text': response.data.message}, true);
            } else {
                flash.setMessage({'type': 'error', 'text': 'Something broke. Retry, or cancel and start afresh.'}, true);
            }
        };
        MediaItemResource.save($scope.mediaItem, successCallback, errorCallback);
    };
    
    $scope.cancel = function() {
        $location.path("/MediaItems");
    };
});