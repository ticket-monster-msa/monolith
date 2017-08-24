'use strict';
define([
    'angular',
    'underscore',
    'configuration',
    'angularRoute',
    'app/api/services'
], function(angular, _, config) {
    angular.module('ticketMonster.bookingView', ['ngRoute', 'ticketMonster.api'])
        .config(['$routeProvider', function($routeProvider) {
            $routeProvider
                .when('/book/:showId/:performanceId', {
                    templateUrl: 'resources/js/app/booking/booking.html',
                    controller: 'BookingController'
                })
                .when('/bookings', {
                    templateUrl: 'resources/js/app/booking/booking-list.html',
                    controller: 'BookingListController'
                })
                .when('/bookings/:bookingId', {
                    templateUrl: 'resources/js/app/booking/booking-detail.html',
                    controller: 'BookingDetailController'
                });

        }])
        .filter('offset', function() {
            return function(input, start) {
                start = parseInt(start, 10);
                return input.slice(start);
            };
        })
        .directive('addTickets', function() {
            var link = function(scope, element, attributes) {

            };

            return {
                controller: "TicketsController",
                scope: false,
                link: link,
                restrict: "A",
                templateUrl: "resources/js/app/booking/add-tickets.html"
            };
        })
        .directive('checkoutBooking', function() {
            var link = function(scope, element, attributes) {

            };

            return {
                controller: "CheckoutController",
                scope: false,
                link: link,
                restrict: "A",
                templateUrl: "resources/js/app/booking/checkout-booking.html"
            };
        })
        .factory("BookingService", function() {
            var cart = {};

            cart.reset = function() {
                cart.tickets = [];
                cart.totals = [];
                cart.performance = {};
                cart.updateTotals();
            };

            cart.getTotals = function() {
                return cart.totals;
            };

            cart.getPerformance = function() {
                return cart.performance;
            };

            cart.setPerformance = function(performance) {
                cart.performance = performance;
            };

            cart.updateTotals = function() {
                cart.totals = _.reduce(cart.tickets, function (totals, ticketRequest) {
                    return {
                        tickets: totals.tickets + ticketRequest.quantity,
                        price: totals.price + ticketRequest.quantity * ticketRequest.ticketPrice.price
                    };
                }, {tickets: 0, price: 0.0});
            };

            cart.addTicket = function(ticketPrice) {
                var found = false;
                _.each(cart.tickets, function (ticket) {
                    if (ticket.ticketPrice.id == ticketPrice.id) {
                        ticket.quantity += ticketPrice.quantity;
                        found = true;
                    }
                });
                if (!found) {
                    cart.tickets.push({ticketPrice:ticketPrice, quantity:ticketPrice.quantity});
                }
                cart.updateTotals();
            };

            cart.removeTicket = function(index) {
                cart.tickets.splice(index, 1);
                cart.updateTotals();
            };

            cart.isEmpty = function() {
                return (cart.totals.tickets === 0);
            };

            cart.reset();

            return cart;
        })
        .controller('BookingController', ['$scope', '$routeParams', '$location', 'BookingService', function($scope, $routeParams, $location, BookingService) {
            $scope.toggleView = function() {
                $scope.displayView = !$scope.displayView;
            };

            $scope.disableToggle = function() {
                return BookingService.isEmpty();
            };

            $scope.displayView = true;
        }])
        .controller('TicketsController', ['$scope', '$routeParams', '$location', 'BookingService', 'ShowResource', 'BookingResource', function($scope, $routeParams, $location, BookingService, ShowResource, BookingResource) {
            console.log("In Tickets View");

            $scope.show = $scope.show || {};
            $scope.performance = $scope.performance || {};
            $scope.sections = $scope.sections || [];
            $scope.ticketPrices = $scope.ticketPrices || [];

            ShowResource.query({showId:$routeParams.showId}, function(data) {
                console.log("Fetched Show");
                $scope.show = data;
                $scope.performance = _.find($scope.show.performances, function (item) {
                    return item.id == $routeParams.performanceId;
                });
                BookingService.setPerformance($scope.performance);
                var id = function (item) {return item.id;};
                $scope.sections = _.uniq(_.sortBy(_.pluck($scope.show.ticketPrices, 'section'), id), true, id);
            }, function() {
                console.log("Failed to fetch shows");
            });

            $scope.$watch('selectedSection', function(newValue, oldValue) {
                if(newValue) {
                    var sectionPrices = _.filter($scope.show.ticketPrices, function(item) {
                        return item.section.id === newValue.id;
                    });
                    $scope.ticketPrices = angular.copy(sectionPrices);
                } else {
                    $scope.ticketPrices = [];
                }
            });

            $scope.checkTickets = function() {
                var sum = 0;
                _.each($scope.ticketPrices, function(ticketPrice) {
                    sum += (ticketPrice.quantity || 0);
                });
                return sum < 1;
            };

            $scope.addTickets = function() {
                _.each($scope.ticketPrices, function (ticketPrice) {
                    if (ticketPrice.quantity != undefined) {
                        BookingService.addTicket(ticketPrice);
                    }
                });
                $scope.selectedSection = null;
                $scope.toggleView();
            };
        }])
        .controller('CheckoutController', ['$scope', '$routeParams', '$location', 'BookingService', 'ShowResource', 'BookingResource', function($scope, $routeParams, $location, BookingService, ShowResource, BookingResource) {
            console.log("In Booking View");

            $scope.performance = $scope.performance || {};
            $scope.bookingRequest = $scope.bookingRequest || {};
            $scope.tickets = BookingService.tickets;
            $scope.totals = BookingService.getTotals();

            $scope.$watch(function() {
                return BookingService.getTotals();
            }, function(newValue, oldValue) {
                $scope.totals = newValue;
            });

            $scope.removeTicket = function(index) {
                BookingService.removeTicket(index);
            };

            $scope.disableCheckout = function() {
                return !(!BookingService.isEmpty()
                    && $scope.bookingRequest.email != undefined
                    && $scope.bookingRequest.email != '');
            };

            $scope.checkout = function() {
                var bookingRequest = {ticketRequests:[]};
                bookingRequest.ticketRequests = _.map(BookingService.tickets, function (ticket) {
                    return {ticketPrice:ticket.ticketPrice.id, quantity:ticket.quantity}
                });
                bookingRequest.email = $scope.bookingRequest.email;
                bookingRequest.performance = BookingService.getPerformance().id;
                BookingResource.save(bookingRequest, function(data) {
                    BookingService.reset();
                    $location.path('/bookings/' + data.id);
                }, function() {
                    console.log("Failure");
                });
            };
        }])
        .controller('BookingDetailController', ['$scope', '$routeParams', '$location', 'BookingResource', 'PerformanceDetailsResource', function($scope, $routeParams, $location, BookingResource, PerformanceDetailsResource) {

            var displayBooking = function() {
                BookingResource.query({bookingId:$routeParams.bookingId}, function(data) {
                    $scope.booking = data;
                    $scope.performance = PerformanceDetailsResource.query({performanceId:$scope.booking.performance.id});
                }, function() {
                    console.log("Failure");
                });
            };

            displayBooking();
        }])
        .controller('BookingListController', ['$scope', '$routeParams', '$location', 'BookingResource', 'PerformanceDetailsResource', function($scope, $routeParams, $location, BookingResource, PerformanceDetailsResource) {

            $scope.itemsPerPage = 10;
            $scope.currentPage = 1;
            $scope.bookings = [];

            $scope.range = function() {
                var rangeSize = 5;
                var ret = [];
                var start = 1;
                var current = $scope.currentPage;
                var end = $scope.pageCount();

                if (current > end - rangeSize) {
                    current = end - rangeSize + 1;
                    if(current < 1) {
                        current = 1;
                    }
                }

                for (var i=current; i<current+rangeSize && i <= end; i++) {
                    ret.push(i);
                }
                return ret;
            };

            $scope.prevPage = function() {
                if ($scope.currentPage > 1) {
                    $scope.currentPage--;
                }
            };

            $scope.prevPageDisabled = function() {
                return $scope.currentPage === 1 ? "disabled" : "";
            };

            $scope.pageCount = function() {
                var count = Math.ceil($scope.bookings.length/$scope.itemsPerPage);
                return count == 0 ? 1 : count;
            };

            $scope.nextPage = function() {
                if ($scope.currentPage < $scope.pageCount()) {
                    $scope.currentPage++;
                }
            };

            $scope.nextPageDisabled = function() {
                return $scope.currentPage === $scope.pageCount() ? "disabled" : "";
            };

            $scope.setPage = function(n) {
                $scope.currentPage = n;
            };

            $scope.displayBookings = function() {
                BookingResource.queryAll(function(data) {
                    $scope.bookings = data;
                    var displayOffset = ($scope.currentPage - 1) * $scope.itemsPerPage;
                    var itemsToDisplay = $scope.bookings.slice(displayOffset);
                    if(itemsToDisplay < 1) {
                        $scope.prevPage();
                    }
                }, function() {
                    console.log("Failure");
                });
            };

            $scope.deleteBooking = function(id) {
                if (confirm("Are you sure you want to delete booking " + id)) {
                    BookingResource.delete({bookingId:id}, function() {
                        $scope.displayBookings();
                    }, function() {
                        console.log("Failure");
                    });
                };
            };

            $scope.displayBookings();
        }]);
});