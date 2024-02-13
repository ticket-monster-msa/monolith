
angular.module('ticketmonster').controller('NewPerformanceController', function ($scope, $location, locationParser, flash, PerformanceResource , ShowResource) {
    $scope.disabled = false;
    $scope.$location = $location;
    $scope.performance = $scope.performance || {};
    
    $scope.showList = ShowResource.queryAll(function(items){
        $scope.showSelectionList = $.map(items, function(item) {
            return ( {
                value : item.id,
                text : item.displayTitle
            });
        });
    });
    $scope.$watch("showSelection", function(selection) {
        if ( typeof selection != 'undefined') {
            $scope.performance.show = {};
            $scope.performance.show.id = selection.value;
        }
    });
    

    $scope.save = function() {
        var successCallback = function(data,responseHeaders){
            var id = locationParser(responseHeaders);
            flash.setMessage({'type':'success','text':'The performance was created successfully.'});
            $location.path('/Performances');
        };
        var errorCallback = function(response) {
            if(response && response.data && response.data.message) {
                flash.setMessage({'type': 'error', 'text': response.data.message}, true);
            } else {
                flash.setMessage({'type': 'error', 'text': 'Something broke. Retry, or cancel and start afresh.'}, true);
            }
        };
        PerformanceResource.save($scope.performance, successCallback, errorCallback);
    };
    
    $scope.cancel = function() {
        $location.path("/Performances");
    };
});