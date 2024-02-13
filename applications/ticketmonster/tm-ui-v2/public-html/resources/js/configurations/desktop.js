/**
 * Shortcut alias definitions - will come in handy when declaring dependencies
 * Also, they allow you to keep the code free of any knowledge about library
 * locations and versions
 */
requirejs.config({
    baseUrl: "resources/js",
    paths: {
        jquery:'libs/jquery-2.1.1',
        underscore:'libs/underscore',
        text:'libs/text',
        bootstrap: 'libs/bootstrap',
        angular: 'libs/angular',
        angularRoute: 'libs/angular-route',
        angularResource: 'libs/angular-resource',
        router: 'app/aggregator/desktop'
    },
    // We shim Angular and Underscore.js since they don't declare AMD modules
    shim: {
        'angular': {'exports' : 'angular'},

        'angularRoute': {
        	deps: ['angular']
        },

        'angularResource': {
            deps: ['angular']
        },

        'underscore': {
            exports: '_'
        }
    },
    priority: [
        "angular"
    ]
});

// Now we declare all the dependencies
// This loads and runs the 'initializer' and 'router' modules.
require([
        'jquery',
        'angular',
        'router'
    ], function($, angular, app) {
        // Configure jQuery to append timestamps to requests, to bypass browser caches
        // Important for MSIE
        $.ajaxSetup({cache:false});
        $('head').append('<link rel="stylesheet" href="resources/css/bootstrap.css" type="text/css" media="all"/>');
        $('head').append('<link rel="stylesheet" href="resources/css/bootstrap-theme.css" type="text/css" media="all"/>');
        $('head').append('<link rel="stylesheet" href="resources/css/screen.css" type="text/css" media="all"/>');
        $('head').append('<link href="http://fonts.googleapis.com/css?family=Rokkitt" rel="stylesheet" type="text/css">');

        $.ajax({
            url:'resources/js/app/aggregator/main.html',
            type: "GET",
            success: function(data) {
                $('body').append(data);
                angular.element().ready(function() {
                    // bootstrap the app manually
                    angular.bootstrap(document, ['ticketMonster']);
                });
            }
        });
    }
);

define("configuration", {
    baseUrl : ""
});