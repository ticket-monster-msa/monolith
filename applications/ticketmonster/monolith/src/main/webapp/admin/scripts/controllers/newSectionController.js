
angular.module('ticketmonster').controller('NewSectionController', function ($scope, $location, locationParser, flash, SectionResource , VenueResource) {
    $scope.disabled = false;
    $scope.$location = $location;
    $scope.section = $scope.section || {};
    
    $scope.venueList = VenueResource.queryAll(function(items){
        $scope.venueSelectionList = $.map(items, function(item) {
            return ( {
                value : item.id,
                text : item.name
            });
        });
    });
    $scope.$watch("venueSelection", function(selection) {
        if ( typeof selection != 'undefined') {
            $scope.section.venue = {};
            $scope.section.venue.id = selection.value;
        }
    });
    

    $scope.save = function() {
        var successCallback = function(data,responseHeaders){
            var id = locationParser(responseHeaders);
            flash.setMessage({'type':'success','text':'The section was created successfully.'});
            $location.path('/Sections');
        };
        var errorCallback = function(response) {
            if(response && response.data && response.data.message) {
                flash.setMessage({'type': 'error', 'text': response.data.message}, true);
            } else {
                flash.setMessage({'type': 'error', 'text': 'Something broke. Retry, or cancel and start afresh.'}, true);
            }
        };
        SectionResource.save($scope.section, successCallback, errorCallback);
    };
    
    $scope.cancel = function() {
        $location.path("/Sections");
    };
});