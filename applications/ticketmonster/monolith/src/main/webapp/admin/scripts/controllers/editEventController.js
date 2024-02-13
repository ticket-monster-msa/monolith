

angular.module('ticketmonster').controller('EditEventController', function($scope, $routeParams, $location, flash, EventResource , MediaItemResource, EventCategoryResource) {
    var self = this;
    $scope.disabled = false;
    $scope.$location = $location;
    
    $scope.get = function() {
        var successCallback = function(data){
            self.original = data;
            $scope.event = new EventResource(self.original);
            MediaItemResource.queryAll(function(items) {
                $scope.mediaItemSelectionList = $.map(items, function(item) {
                    var wrappedObject = {
                        id : item.id
                    };
                    var labelObject = {
                        value : item.id,
                        text : item.url
                    };
                    if($scope.event.mediaItem && item.id == $scope.event.mediaItem.id) {
                        $scope.mediaItemSelection = labelObject;
                        $scope.event.mediaItem = wrappedObject;
                        self.original.mediaItem = $scope.event.mediaItem;
                    }
                    return labelObject;
                });
            });
            EventCategoryResource.queryAll(function(items) {
                $scope.categorySelectionList = $.map(items, function(item) {
                    var wrappedObject = {
                        id : item.id
                    };
                    var labelObject = {
                        value : item.id,
                        text : item.description
                    };
                    if($scope.event.category && item.id == $scope.event.category.id) {
                        $scope.categorySelection = labelObject;
                        $scope.event.category = wrappedObject;
                        self.original.category = $scope.event.category;
                    }
                    return labelObject;
                });
            });
        };
        var errorCallback = function() {
            flash.setMessage({'type': 'error', 'text': 'The event could not be found.'});
            $location.path("/Events");
        };
        EventResource.get({EventId:$routeParams.EventId}, successCallback, errorCallback);
    };

    $scope.isClean = function() {
        return angular.equals(self.original, $scope.event);
    };

    $scope.save = function() {
        var successCallback = function(){
            flash.setMessage({'type':'success','text':'The event was updated successfully.'}, true);
            $scope.get();
        };
        var errorCallback = function(response) {
            if(response && response.data && response.data.message) {
                flash.setMessage({'type': 'error', 'text': response.data.message}, true);
            } else {
                flash.setMessage({'type': 'error', 'text': 'Something broke. Retry, or cancel and start afresh.'}, true);
            }
        };
        $scope.event.$update(successCallback, errorCallback);
    };

    $scope.cancel = function() {
        $location.path("/Events");
    };

    $scope.remove = function() {
        var successCallback = function() {
            flash.setMessage({'type': 'error', 'text': 'The event was deleted.'});
            $location.path("/Events");
        };
        var errorCallback = function(response) {
            if(response && response.data && response.data.message) {
                flash.setMessage({'type': 'error', 'text': response.data.message}, true);
            } else {
                flash.setMessage({'type': 'error', 'text': 'Something broke. Retry, or cancel and start afresh.'}, true);
            }
        }; 
        $scope.event.$remove(successCallback, errorCallback);
    };
    
    $scope.$watch("mediaItemSelection", function(selection) {
        if (typeof selection != 'undefined') {
            $scope.event.mediaItem = {};
            $scope.event.mediaItem.id = selection.value;
        }
    });
    $scope.$watch("categorySelection", function(selection) {
        if (typeof selection != 'undefined') {
            $scope.event.category = {};
            $scope.event.category.id = selection.value;
        }
    });
    
    $scope.get();
});