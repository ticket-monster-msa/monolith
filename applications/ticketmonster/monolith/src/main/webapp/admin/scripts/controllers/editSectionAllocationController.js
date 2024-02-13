

angular.module('ticketmonster').controller('EditSectionAllocationController', function($scope, $routeParams, $location, flash, SectionAllocationResource , PerformanceResource, SectionResource) {
    var self = this;
    $scope.disabled = false;
    $scope.$location = $location;
    
    $scope.get = function() {
        var successCallback = function(data){
            self.original = data;
            $scope.sectionAllocation = new SectionAllocationResource(self.original);
            PerformanceResource.queryAll(function(items) {
                $scope.performanceSelectionList = $.map(items, function(item) {
                    var wrappedObject = {
                        id : item.id
                    };
                    var labelObject = {
                        value : item.id,
                        text : item.displayTitle
                    };
                    if($scope.sectionAllocation.performance && item.id == $scope.sectionAllocation.performance.id) {
                        $scope.performanceSelection = labelObject;
                        $scope.sectionAllocation.performance = wrappedObject;
                        self.original.performance = $scope.sectionAllocation.performance;
                    }
                    return labelObject;
                });
            });
            SectionResource.queryAll(function(items) {
                $scope.sectionSelectionList = $.map(items, function(item) {
                    var wrappedObject = {
                        id : item.id
                    };
                    var labelObject = {
                        value : item.id,
                        text : item.name
                    };
                    if($scope.sectionAllocation.section && item.id == $scope.sectionAllocation.section.id) {
                        $scope.sectionSelection = labelObject;
                        $scope.sectionAllocation.section = wrappedObject;
                        self.original.section = $scope.sectionAllocation.section;
                    }
                    return labelObject;
                });
            });
        };
        var errorCallback = function() {
            flash.setMessage({'type': 'error', 'text': 'The sectionAllocation could not be found.'});
            $location.path("/SectionAllocations");
        };
        SectionAllocationResource.get({SectionAllocationId:$routeParams.SectionAllocationId}, successCallback, errorCallback);
    };

    $scope.isClean = function() {
        return angular.equals(self.original, $scope.sectionAllocation);
    };

    $scope.save = function() {
        var successCallback = function(){
            flash.setMessage({'type':'success','text':'The sectionAllocation was updated successfully.'}, true);
            $scope.get();
        };
        var errorCallback = function(response) {
            if(response && response.data && response.data.message) {
                flash.setMessage({'type': 'error', 'text': response.data.message}, true);
            } else {
                flash.setMessage({'type': 'error', 'text': 'Something broke. Retry, or cancel and start afresh.'}, true);
            }
        };
        $scope.sectionAllocation.$update(successCallback, errorCallback);
    };

    $scope.cancel = function() {
        $location.path("/SectionAllocations");
    };

    $scope.remove = function() {
        var successCallback = function() {
            flash.setMessage({'type': 'error', 'text': 'The sectionAllocation was deleted.'});
            $location.path("/SectionAllocations");
        };
        var errorCallback = function(response) {
            if(response && response.data && response.data.message) {
                flash.setMessage({'type': 'error', 'text': response.data.message}, true);
            } else {
                flash.setMessage({'type': 'error', 'text': 'Something broke. Retry, or cancel and start afresh.'}, true);
            }
        }; 
        $scope.sectionAllocation.$remove(successCallback, errorCallback);
    };
    
    $scope.$watch("performanceSelection", function(selection) {
        if (typeof selection != 'undefined') {
            $scope.sectionAllocation.performance = {};
            $scope.sectionAllocation.performance.id = selection.value;
        }
    });
    $scope.$watch("sectionSelection", function(selection) {
        if (typeof selection != 'undefined') {
            $scope.sectionAllocation.section = {};
            $scope.sectionAllocation.section.id = selection.value;
        }
    });
    
    $scope.get();
});