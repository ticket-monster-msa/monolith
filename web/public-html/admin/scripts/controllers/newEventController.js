
angular.module('ticketmonster').controller('NewEventController', function ($scope, $location, locationParser, flash, EventResource , MediaItemResource, EventCategoryResource) {
    $scope.disabled = false;
    $scope.$location = $location;
    $scope.event = $scope.event || {};
    
    $scope.mediaItemList = MediaItemResource.queryAll(function(items){
        $scope.mediaItemSelectionList = $.map(items, function(item) {
            return ( {
                value : item.id,
                text : item.url
            });
        });
    });
    $scope.$watch("mediaItemSelection", function(selection) {
        if ( typeof selection != 'undefined') {
            $scope.event.mediaItem = {};
            $scope.event.mediaItem.id = selection.value;
        }
    });
    
    $scope.categoryList = EventCategoryResource.queryAll(function(items){
        $scope.categorySelectionList = $.map(items, function(item) {
            return ( {
                value : item.id,
                text : item.description
            });
        });
    });
    $scope.$watch("categorySelection", function(selection) {
        if ( typeof selection != 'undefined') {
            $scope.event.category = {};
            $scope.event.category.id = selection.value;
        }
    });
    

    $scope.save = function() {
        var successCallback = function(data,responseHeaders){
            var id = locationParser(responseHeaders);
            flash.setMessage({'type':'success','text':'The event was created successfully.'});
            $location.path('/Events');
        };
        var errorCallback = function(response) {
            if(response && response.data && response.data.message) {
                flash.setMessage({'type': 'error', 'text': response.data.message}, true);
            } else {
                flash.setMessage({'type': 'error', 'text': 'Something broke. Retry, or cancel and start afresh.'}, true);
            }
        };
        EventResource.save($scope.event, successCallback, errorCallback);
    };
    
    $scope.cancel = function() {
        $location.path("/Events");
    };
});