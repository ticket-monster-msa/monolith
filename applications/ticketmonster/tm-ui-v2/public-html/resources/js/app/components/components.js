'use strict';
define([
    'angular',
    'bootstrap'
], function (angular) {
    angular.module('ticketMonster.ui.components',[])
        .directive('menuPopover', function () {
            return {
                restrict: 'A',
                template: '',
                link: function (scope, el, attrs) {
                    if (!Modernizr.touch) {
                        $(el).popover({
                            trigger: 'hover',
                            container: '#content',
                            content: attrs.content,
                            title: attrs.originalTitle
                        }).data('bs.popover')
                            .tip()
                            .addClass('visible-lg')
                            .addClass('visible-md');
                    }
                }
            };
        });
});