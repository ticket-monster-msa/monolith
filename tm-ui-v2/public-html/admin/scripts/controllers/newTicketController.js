
angular.module('ticketmonster').controller('NewTicketController', function ($scope, $location, locationParser, flash, TicketResource , TicketCategoryResource, SectionResource) {
    $scope.disabled = false;
    $scope.$location = $location;
    $scope.ticket = $scope.ticket || {};
    
    $scope.ticketCategoryList = TicketCategoryResource.queryAll(function(items){
        $scope.ticketCategorySelectionList = $.map(items, function(item) {
            return ( {
                value : item.id,
                text : item.description
            });
        });
    });
    $scope.$watch("ticketCategorySelection", function(selection) {
        if ( typeof selection != 'undefined') {
            $scope.ticket.ticketCategory = {};
            $scope.ticket.ticketCategory.id = selection.value;
        }
    });
    
    $scope.seatsectionList = SectionResource.queryAll(function(items){
        $scope.seatsectionSelectionList = $.map(items, function(item) {
            return ( {
                value : item.id,
                text : item.name
            });
        });
    });
    $scope.$watch("seatsectionSelection", function(selection) {
        if ( typeof selection != 'undefined') {
            $scope.ticket.seat.section = {};
            $scope.ticket.seat.section.id = selection.value;
        }
    });
    

    $scope.save = function() {
        var successCallback = function(data,responseHeaders){
            var id = locationParser(responseHeaders);
            flash.setMessage({'type':'success','text':'The ticket was created successfully.'});
            $location.path('/Tickets');
        };
        var errorCallback = function(response) {
            if(response && response.data && response.data.message) {
                flash.setMessage({'type': 'error', 'text': response.data.message}, true);
            } else {
                flash.setMessage({'type': 'error', 'text': 'Something broke. Retry, or cancel and start afresh.'}, true);
            }
        };
        TicketResource.save($scope.ticket, successCallback, errorCallback);
    };
    
    $scope.cancel = function() {
        $location.path("/Tickets");
    };
});