'use strict';
define([
    'angular',
    'angularRoute'
], function(angular) {
    angular.module('ticketMonster.homeView', ['ngRoute'])
        .config(['$routeProvider', function($routeProvider) {
            $routeProvider.when('/', {
                templateUrl: 'resources/js/app/home/home.html',
                controller: 'HomeController'
            });
        }])
        .controller('HomeController', [function() {

        }]);
});