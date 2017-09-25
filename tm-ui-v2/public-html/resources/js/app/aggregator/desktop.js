'use strict';

/**
 * A module for the router of the desktop application
 */
define("router", [
    'angular',
    'angularRoute',
    'angularResource',
    'app/home/view',
    'app/events/eventsView',
    'app/venues/venuesView',
    'app/eventDetail/eventDetailView',
    'app/venueDetail/venueDetailView',
    'app/booking/view',
    'app/monitor/monitor'
],function (angular) {

    return angular.module('ticketMonster', ['ngRoute',
        'ngResource',
        'ticketMonster.api',
        'ticketMonster.homeView',
        'ticketMonster.eventsView',
        'ticketMonster.venuesView',
        'ticketMonster.eventDetailView',
        'ticketMonster.venueDetailView',
        'ticketMonster.bookingView',
        'ticketMonster.monitorView'])
        .config(['$routeProvider', function($routeProvider) {
            $routeProvider
                .otherwise({redirectTo: '/'});
        }]);
});