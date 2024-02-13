
angular.module('ticketmonster').controller('NewSectionAllocationController', function ($scope, $location, locationParser, flash, SectionAllocationResource , PerformanceResource, SectionResource) {
    $scope.disabled = false;
    $scope.$location = $location;
    $scope.sectionAllocation = $scope.sectionAllocation || {};
    
    $scope.performanceList = PerformanceResource.queryAll(function(items){
        $scope.performanceSelectionList = $.map(items, function(item) {
            return ( {
                value : item.id,
                text : item.displayTitle
            });
        });
    });
    $scope.$watch("performanceSelection", function(selection) {
        if ( typeof selection != 'undefined') {
            $scope.sectionAllocation.performance = {};
            $scope.sectionAllocation.performance.id = selection.value;
        }
    });
    
    $scope.sectionList = SectionResource.queryAll(function(items){
        $scope.sectionSelectionList = $.map(items, function(item) {
            return ( {
                value : item.id,
                text : item.name
            });
        });
    });
    $scope.$watch("sectionSelection", function(selection) {
        if ( typeof selection != 'undefined') {
            $scope.sectionAllocation.section = {};
            $scope.sectionAllocation.section.id = selection.value;
        }
    });
    

    $scope.save = function() {
        var successCallback = function(data,responseHeaders){
            var id = locationParser(responseHeaders);
            flash.setMessage({'type':'success','text':'The sectionAllocation was created successfully.'});
            $location.path('/SectionAllocations');
        };
        var errorCallback = function(response) {
            if(response && response.data && response.data.message) {
                flash.setMessage({'type': 'error', 'text': response.data.message}, true);
            } else {
                flash.setMessage({'type': 'error', 'text': 'Something broke. Retry, or cancel and start afresh.'}, true);
            }
        };
        SectionAllocationResource.save($scope.sectionAllocation, successCallback, errorCallback);
    };
    
    $scope.cancel = function() {
        $location.path("/SectionAllocations");
    };
});