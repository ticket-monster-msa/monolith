

angular.module('ticketmonster').controller('EditPerformanceController', function($scope, $routeParams, $location, flash, PerformanceResource , ShowResource) {
    var self = this;
    $scope.disabled = false;
    $scope.$location = $location;
    
    $scope.get = function() {
        var successCallback = function(data){
            self.original = data;
            $scope.performance = new PerformanceResource(self.original);
            ShowResource.queryAll(function(items) {
                $scope.showSelectionList = $.map(items, function(item) {
                    var wrappedObject = {
                        id : item.id
                    };
                    var labelObject = {
                        value : item.id,
                        text : item.displayTitle
                    };
                    if($scope.performance.show && item.id == $scope.performance.show.id) {
                        $scope.showSelection = labelObject;
                        $scope.performance.show = wrappedObject;
                        self.original.show = $scope.performance.show;
                    }
                    return labelObject;
                });
            });
        };
        var errorCallback = function() {
            flash.setMessage({'type': 'error', 'text': 'The performance could not be found.'});
            $location.path("/Performances");
        };
        PerformanceResource.get({PerformanceId:$routeParams.PerformanceId}, successCallback, errorCallback);
    };

    $scope.isClean = function() {
        return angular.equals(self.original, $scope.performance);
    };

    $scope.save = function() {
        var successCallback = function(){
            flash.setMessage({'type':'success','text':'The performance was updated successfully.'}, true);
            $scope.get();
        };
        var errorCallback = function(response) {
            if(response && response.data && response.data.message) {
                flash.setMessage({'type': 'error', 'text': response.data.message}, true);
            } else {
                flash.setMessage({'type': 'error', 'text': 'Something broke. Retry, or cancel and start afresh.'}, true);
            }
        };
        $scope.performance.$update(successCallback, errorCallback);
    };

    $scope.cancel = function() {
        $location.path("/Performances");
    };

    $scope.remove = function() {
        var successCallback = function() {
            flash.setMessage({'type': 'error', 'text': 'The performance was deleted.'});
            $location.path("/Performances");
        };
        var errorCallback = function(response) {
            if(response && response.data && response.data.message) {
                flash.setMessage({'type': 'error', 'text': response.data.message}, true);
            } else {
                flash.setMessage({'type': 'error', 'text': 'Something broke. Retry, or cancel and start afresh.'}, true);
            }
        }; 
        $scope.performance.$remove(successCallback, errorCallback);
    };
    
    $scope.$watch("showSelection", function(selection) {
        if (typeof selection != 'undefined') {
            $scope.performance.show = {};
            $scope.performance.show.id = selection.value;
        }
    });
    
    $scope.get();
});