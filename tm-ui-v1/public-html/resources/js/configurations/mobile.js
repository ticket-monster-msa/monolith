/**
 * Shortcut alias definitions - will come in handy when declaring dependencies
 * Also, they allow you to keep the code free of any knowledge about library
 * locations and versions
 */
require.config({
    baseUrl:"resources/js",
    paths: {
        jquery:'libs/jquery-2.1.1',
        underscore:'libs/underscore',
        text:'libs/text',
        bootstrap: 'libs/bootstrap',
        angular: 'libs/angular',
        angularRoute: 'libs/angular-route',
        angularResource: 'libs/angular-resource',
        angularTouch: 'libs/angular-touch',
        router: 'app/aggregator/mobile'
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

        'angularTouch': {
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

define("configuration", function() {
    if (window.TicketMonster != undefined && TicketMonster.config != undefined) {
        return {
            baseUrl: TicketMonster.config.baseRESTUrl
        };
    } else {
        return {
            baseUrl: ""
        };
    }
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
        if(!window.cordova) {
            $('head').append('<link href="http://fonts.googleapis.com/css?family=Rokkitt" rel="stylesheet" type="text/css">');
        }

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