
angular.module('ticketmonster').controller('NewTicketCategoryController', function ($scope, $location, locationParser, flash, TicketCategoryResource ) {
    $scope.disabled = false;
    $scope.$location = $location;
    $scope.ticketCategory = $scope.ticketCategory || {};
    

    $scope.save = function() {
        var successCallback = function(data,responseHeaders){
            var id = locationParser(responseHeaders);
            flash.setMessage({'type':'success','text':'The ticketCategory was created successfully.'});
            $location.path('/TicketCategories');
        };
        var errorCallback = function(response) {
            if(response && response.data && response.data.message) {
                flash.setMessage({'type': 'error', 'text': response.data.message}, true);
            } else {
                flash.setMessage({'type': 'error', 'text': 'Something broke. Retry, or cancel and start afresh.'}, true);
            }
        };
        TicketCategoryResource.save($scope.ticketCategory, successCallback, errorCallback);
    };
    
    $scope.cancel = function() {
        $location.path("/TicketCategories");
    };
});