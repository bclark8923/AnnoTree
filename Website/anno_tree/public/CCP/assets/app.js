'use strict';

var AnnoTreeCCP = angular.module('AnnoTreeCCP', ['ngResource']);

AnnoTreeCCP.config(function($routeProvider) {
                   
                   $routeProvider.
                   when('/login', {
                        controller: 'LoginController',
                        templateUrl: 'views/loginScreen.html'
                        }).
                   when('/app', {
                        action: 'ccp.forest'
                        }).
                   when('/app/:treeId', {
                        action: 'ccp.forest.tree'
                        }).
                   when('/app/:treeId/:leafId', {
                        action: 'ccp.forest.leaf'
                        });
                   });

AnnoTreeCCP.filter('treeRowFilter', function() {
             return function(arrayLength) {
                   arrayLength = Math.ceil(arrayLength);
                   var arr = new Array(arrayLength), i = 0;
                   for (; i < arrayLength; i++) {
                    arr[i] = i;
                   }      
                   return arr;
             };
});