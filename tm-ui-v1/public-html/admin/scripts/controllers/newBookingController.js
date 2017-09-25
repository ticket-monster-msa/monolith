
angular.module('ticketmonster').controller('NewBookingController', function ($scope, $location, locationParser, flash, BookingResource , TicketResource, PerformanceResource) {
    $scope.disabled = false;
    $scope.$location = $location;
    $scope.booking = $scope.booking || {};
    
    $scope.ticketsList = TicketResource.queryAll(function(items){
        $scope.ticketsSelectionList = $.map(items, function(item) {
            return ( {
                value : item.id,
                text : item.price
            });
        });
    });
    $scope.$watch("ticketsSelection", function(selection) {
        if (typeof selection != 'undefined') {
            $scope.booking.tickets = [];
            $.each(selection, function(idx,selectedItem) {
                var collectionItem = {};
                collectionItem.id = selectedItem.value;
                $scope.booking.tickets.push(collectionItem);
            });
        }
    });

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
            $scope.booking.performance = {};
            $scope.booking.performance.id = selection.value;
        }
    });
    

    $scope.save = function() {
        var successCallback = function(data,responseHeaders){
            var id = locationParser(responseHeaders);
            flash.setMessage({'type':'success','text':'The booking was created successfully.'});
            $location.path('/Bookings');
        };
        var errorCallback = function(response) {
            if(response && response.data && response.data.message) {
                flash.setMessage({'type': 'error', 'text': response.data.message}, true);
            } else {
                flash.setMessage({'type': 'error', 'text': 'Something broke. Retry, or cancel and start afresh.'}, true);
            }
        };
        BookingResource.save($scope.booking, successCallback, errorCallback);
    };
    
    $scope.cancel = function() {
        $location.path("/Bookings");
    };
});