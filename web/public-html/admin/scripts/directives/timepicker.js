'use strict';

var TIME_REGEX = /^([0-5][0-9])\:([0-5][0-9])(?:\:([0-5][0-9]))?$/;
angular.module('ticketmonster').directive('time', function($parse, dateFilter) {
    return {
        restrict : "E",
        replace : true,
        transclude : false,
        require: '?ngModel',
        compile : function(element, attrs) {
            var modelAccessor = $parse(attrs.ngModel);

            var isRequired = "";
            if(attrs.required) {
                isRequired = "required";
            }
            var html = "<input id='" + attrs.id + "' name='" + attrs.name + "' type='time' " + isRequired + " class='form-control' placeholder='"+attrs.placeholder+"'></input>";

            var $newElem = $(html);
            element.replaceWith($newElem);

            var nativeLinker = function(scope, element, attrs, ngModelCtrl) {
                if(!ngModelCtrl) return;

                var timeParser = function(value) {
                    var date;
                    if(value) {
                    	var d = value.match(TIME_REGEX);
                        if(d) {
                        	date = new Date(0);
                        	if(!d[3]) {
                            	d[3] = "0";
                            }
                    		date.setHours(d[1], d[2], d[3]);
                        } else {
                        	date = value;
                        }
                    } else {
                        date = value;
                    }
                    return date;
                }
                var timeFormatter = function(value) {
                    if(value) {
                        var date = dateFilter(value,"HH:mm:ss");
                        return date;
                    }
                    return;
                }

                ngModelCtrl.$parsers.unshift(timeParser);
                ngModelCtrl.$formatters.unshift(timeFormatter);

                element.bind("blur keyup change", function() {
                    scope.$apply(function() {
                        ngModelCtrl.$setViewValue(element.val());
                    });
                });

                ngModelCtrl.$render = function() {
                    element.val(ngModelCtrl.$viewValue);
                }
            }

            var enhancedLinker = function(scope, element, attrs, ngModelCtrl) {
                if(!ngModelCtrl) return;
                
                var timeParser = function(value) {
                    if(value) {
                        var d = value.match(TIME_REGEX);
                        if(d) {
                            var date = new Date(0);
                            if(!d[3]) {
                            	d[3] = "0";
                            }
                            date.setHours(d[1], d[2], d[3]);
                            ngModelCtrl.$setValidity("timeFormat", true);
                            return date;
                        } else {
                            ngModelCtrl.$setValidity("timeFormat", false);
                            return;
                        }
                    }
                    return;
                }
                var timeFormatter = function(value) {
                    if(value) {
                        var date = dateFilter(value,"HH:mm:ss");
                        return date;
                    }
                    return;
                }
                
                ngModelCtrl.$parsers.unshift(timeParser);
                ngModelCtrl.$formatters.unshift(timeFormatter);

                element.bind("blur keyup change", function() {
                    scope.$apply(function() {
                        ngModelCtrl.$setViewValue(element.val());
                    });
                });

                ngModelCtrl.$render = function() {
                    element.val(ngModelCtrl.$viewValue);
                }
            }

            if(Modernizr.inputtypes["time"]) {
                return nativeLinker;
            } else {
                return enhancedLinker;
            }
        }
    }
});