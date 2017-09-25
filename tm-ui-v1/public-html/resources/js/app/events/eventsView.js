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
    angular.module('ticketMonster.eventsView', ['ngRoute', 'ngResource', 'ticketMonster.api', 'ticketMonster.ui.components'])
        .config(['$routeProvider', function($routeProvider) {
            $routeProvider.when('/events', {
                templateUrl: 'resources/js/app/events/events.html',
                controller: 'EventsController'
            });
        }])
        .controller('EventsController', ['$scope','EventResource', function($scope, EventResource) {
        	$scope.config = config;
            $scope.events = EventResource.queryAll(function(data) {
                $scope.events = data;
                $scope.categories = _.uniq(
                    _.map($scope.events, function(event){
                        return event.category;
                    }), false, function(item){
                        return item.id;
                    });
                $('.carousel-inner').find('.item:first').addClass('active');
                $(".carousel").carousel();
            });
        }]);
});