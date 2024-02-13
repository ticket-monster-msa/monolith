
angular.module('ticketmonster').controller('NewEventCategoryController', function ($scope, $location, locationParser, flash, EventCategoryResource ) {
    $scope.disabled = false;
    $scope.$location = $location;
    $scope.eventCategory = $scope.eventCategory || {};
    

    $scope.save = function() {
        var successCallback = function(data,responseHeaders){
            var id = locationParser(responseHeaders);
            flash.setMessage({'type':'success','text':'The eventCategory was created successfully.'});
            $location.path('/EventCategories');
        };
        var errorCallback = function(response) {
            if(response && response.data && response.data.message) {
                flash.setMessage({'type': 'error', 'text': response.data.message}, true);
            } else {
                flash.setMessage({'type': 'error', 'text': 'Something broke. Retry, or cancel and start afresh.'}, true);
            }
        };
        EventCategoryResource.save($scope.eventCategory, successCallback, errorCallback);
    };
    
    $scope.cancel = function() {
        $location.path("/EventCategories");
    };
});