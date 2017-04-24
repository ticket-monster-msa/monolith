'use strict';

angular.module('ticketmonster').factory('flash', ['$rootScope', function ($rootScope) {
    var messages = [];
    var currentMessage = {};

    $rootScope.$on('$routeChangeSuccess', function() {
      currentMessage = messages.shift() || {};
    });

    return {
      getMessage: function () {
        return currentMessage;
      },
      setMessage: function(message, pop) {
        switch(message.type) {
            case "error" : message.cssClass = "danger"; break;
            case "success" : message.cssClass = "success"; break;
            case "info" : message.cssClass = "info"; break;
            case "warning" : message.cssClass = "warning"; break;
        }
        messages.push(message);
        if(pop) {
          currentMessage = messages.shift() || {};
        }
      }
    };
}]);
