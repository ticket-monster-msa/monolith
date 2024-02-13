

angular.module('ticketmonster').controller('EditBookingController', function($scope, $routeParams, $location, flash, BookingResource , TicketResource, PerformanceResource) {
    var self = this;
    $scope.disabled = false;
    $scope.$location = $location;
    
    $scope.get = function() {
        var successCallback = function(data){
            self.original = data;
            $scope.booking = new BookingResource(self.original);
            TicketResource.queryAll(function(items) {
                $scope.ticketsSelectionList = $.map(items, function(item) {
                    var wrappedObject = {
                        id : item.id
                    };
                    var labelObject = {
                        value : item.id,
                        text : item.price
                    };
                    if($scope.booking.tickets){
                        $.each($scope.booking.tickets, function(idx, element) {
                            if(item.id == element.id) {
                                $scope.ticketsSelection.push(labelObject);
                                $scope.booking.tickets.push(wrappedObject);
                            }
                        });
                        self.original.tickets = $scope.booking.tickets;
                    }
                    return labelObject;
                });
            });
            PerformanceResource.queryAll(function(items) {
                $scope.performanceSelectionList = $.map(items, function(item) {
                    var wrappedObject = {
                        id : item.id
                    };
                    var labelObject = {
                        value : item.id,
                        text : item.displayTitle
                    };
                    if($scope.booking.performance && item.id == $scope.booking.performance.id) {
                        $scope.performanceSelection = labelObject;
                        $scope.booking.performance = wrappedObject;
                        self.original.performance = $scope.booking.performance;
                    }
                    return labelObject;
                });
            });
        };
        var errorCallback = function() {
            flash.setMessage({'type': 'error', 'text': 'The booking could not be found.'});
            $location.path("/Bookings");
        };
        BookingResource.get({BookingId:$routeParams.BookingId}, successCallback, errorCallback);
    };

    $scope.isClean = function() {
        return angular.equals(self.original, $scope.booking);
    };

    $scope.save = function() {
        var successCallback = function(){
            flash.setMessage({'type':'success','text':'The booking was updated successfully.'}, true);
            $scope.get();
        };
        var errorCallback = function(response) {
            if(response && response.data && response.data.message) {
                flash.setMessage({'type': 'error', 'text': response.data.message}, true);
            } else {
                flash.setMessage({'type': 'error', 'text': 'Something broke. Retry, or cancel and start afresh.'}, true);
            }
        };
        $scope.booking.$update(successCallback, errorCallback);
    };

    $scope.cancel = function() {
        $location.path("/Bookings");
    };

    $scope.remove = function() {
        var successCallback = function() {
            flash.setMessage({'type': 'error', 'text': 'The booking was deleted.'});
            $location.path("/Bookings");
        };
        var errorCallback = function(response) {
            if(response && response.data && response.data.message) {
                flash.setMessage({'type': 'error', 'text': response.data.message}, true);
            } else {
                flash.setMessage({'type': 'error', 'text': 'Something broke. Retry, or cancel and start afresh.'}, true);
            }
        }; 
        $scope.booking.$remove(successCallback, errorCallback);
    };
    
    $scope.ticketsSelection = $scope.ticketsSelection || [];
    $scope.$watch("ticketsSelection", function(selection) {
        if (typeof selection != 'undefined' && $scope.booking) {
            $scope.booking.tickets = [];
            $.each(selection, function(idx,selectedItem) {
                var collectionItem = {};
                collectionItem.id = selectedItem.value;
                $scope.booking.tickets.push(collectionItem);
            });
        }
    });
    $scope.$watch("performanceSelection", function(selection) {
        if (typeof selection != 'undefined') {
            $scope.booking.performance = {};
            $scope.booking.performance.id = selection.value;
        }
    });
    
    $scope.get();
});