'use strict';
define([
    'angular',
    'underscore',
    'configuration',
    'bootstrap',
    'angularRoute',
    'angularResource',
    'app/api/services'
], function(angular, _, config) {
    angular.module('ticketMonster.monitorView', ['ngRoute', 'ngResource', 'ticketMonster.api'])
        .config(['$routeProvider', function($routeProvider) {
            $routeProvider.when('/monitor', {
                templateUrl: 'resources/js/app/monitor/monitor.html',
                controller: 'MonitorController'
            });
        }])
        .controller('MonitorController', ['$scope', '$http', '$timeout', 'EventResource', function($scope, $http, $timeout, EventResource) {

            /**
             * The Bot model class definition
             * Used perform operations on the Bot.
             * Note that this is not a Backbone model.
             */
            var Bot = function() {
                this.statusUrl = config.baseUrl + 'rest/bot/status';
                this.messagesUrl = config.baseUrl + 'rest/bot/messages';
            };

            /*
             * Start the Bot by sending a request to the Bot resource
             * with the new status of the Bot set to "RUNNING".
             */
            Bot.prototype.start = function() {
                $http({
                    method: "PUT",
                    url: this.statusUrl,
                    data: "\"RUNNING\"",
                    responseType: "application/json"
                });
            };

            /*
             * Stop the Bot by sending a request to the Bot resource
             * with the new status of the Bot set to "NOT_RUNNING".
             */
            Bot.prototype.stop = function() {
                $http({
                    method: "PUT",
                    url: this.statusUrl,
                    data: "\"NOT_RUNNING\"",
                    responseType: "application/json"
                });
            };

            /*
             * Stop the Bot and delete all bookings by sending a request to the Bot resource
             * with the new status of the Bot set to "RESET".
             */
            Bot.prototype.reset = function() {
                $http({
                    method: "PUT",
                    url: this.statusUrl,
                    data: "\"RESET\"",
                    responseType: "application/json"
                });
            };

            /*
             * Fetch the log messages of the Bot and invoke the callback.
             * The callback is provided with the log messages (an array of Strings).
             */
            Bot.prototype.fetchMessages = function(callback) {
                $http.get(this.messagesUrl)
                    .then(function(data) {
                        if(callback) {
                            callback(data);
                        }
                    });
            };

            var fetchMetrics = function() {
                $http.get(config.baseUrl + "rest/metrics")
                    .then(function(response){
                        $scope.metrics = response.data;
                    });
            };

            var bot = new Bot();
            var timer = null;
            var poll = function() {
                fetchMetrics();
                bot.fetchMessages(function(response) {
                    $scope.messages = response.data.reverse().join("");
                });
                timer = $timeout(poll, 3000);
            };
            timer = $timeout(poll, 0);

            $scope.startBot = function () {
                bot.start()
            };
            $scope.stopBot = function () {
                bot.stop()
            };
            $scope.resetBot = function () {
                bot.reset()
            };

            $scope.$on("$destroy", function() {
                if(timer) {
                    $timeout.cancel(timer);
                }
            });
        }]);
});