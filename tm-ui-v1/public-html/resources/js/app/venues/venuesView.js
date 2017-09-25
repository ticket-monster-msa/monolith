'use strict';
define([
    'angular',
    'underscore',
    'configuration',
    'bootstrap',
    'angularRoute',
    'angularResource',
    'app/api/services',
    'app/components/components'
], function(angular, _, config) {
    angular.module('ticketMonster.venuesView', ['ngRoute', 'ngResource', 'ticketMonster.api', 'ticketMonster.ui.components'])
        .config(['$routeProvider', function($routeProvider) {
            $routeProvider.when('/venues', {
                templateUrl: 'resources/js/app/venues/venues.html',
                controller: 'VenuesController'
            });
        }])
        .controller('VenuesController', ['$scope','VenueResource', function($scope, VenueResource) {
        	$scope.config = config;
            $scope.venues = VenueResource.queryAll(function(data) {
                $scope.venues = data;
                $scope.cities = _.uniq(
                    _.map($scope.venues, function(venue){
                        return venue.address.city;
                    })
                );
                $('.carousel-inner').find('.item:first').addClass('active');
                $(".carousel").carousel();
            });
        }]);
});