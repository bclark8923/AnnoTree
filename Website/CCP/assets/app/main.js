var AnnoTree = angular.module("AnnoTree", ['ngCookies']);

AnnoTree.run(function($rootScope, $templateCache) {
    $rootScope.$on('$viewContentLoaded', function() {
        $templateCache.removeAll();
    });
});

AnnoTree.config(
    function($routeProvider, $locationProvider, $httpProvider) {
        $routeProvider
            .when("/authenticate/login", {
                action: "authenticate.login"
            })
            .when("/authenticate/signUp", {
                action: "authenticate.signup"
            })
            .when("/authenticate/requestPassword", {
                action: "authenticate.requestPassword"
            })
            .when("/authenticate/resetPassword", {
                action: "authenticate.resetPassword"
            })
            .when("/app", {
                action: "standard.forest"
            })
            .when("/app/ft", {
                action: "standard.forest"
            })
            .when("/app/:treeID/docs", {
                action: "standard.tree.docs.home"
            })
            .when("/app/:treeID", {
                action: "standard.tree.leaves"
            })
            .when("/app/:treeID/:leafID", {
                action: "standard.tree.leaf"
            })
            .when("/forestFire", {
                action: "standard.forestFire"
            })
            .otherwise({
                redirectTo: "/authenticate/login"
            });
     
        $httpProvider.responseInterceptors.push(interceptor);
    }
);

AnnoTree.factory('constants', function() {
    return {
        servicesDown: function() {
            return 'AnnoTree is currently down.  Try again in a few minutes or contact us at support@annotree.com';
        }
    }
});

AnnoTree.factory('apiRoot', function() {
    return {
        getRoot: function() {
            return window.location.protocol + "//" + window.location.host;
        }
    }
});

AnnoTree.directive('postRender', function($timeout) {
    return  { 
        link: function(scope, elm, attrs) { 
            $timeout(function() {
                $("#loadingScreen").hide();
            }, 0);
        }
    }
});

AnnoTree.directive('renderPane', function($timeout) {
    return  { 
        link: function(scope, elm, attrs) { 
            $timeout(function() {
                settingsPane = new SlidingPane({
                    id: 'mobileDashboard',
                    targetId: 'containWrapper',
                    side: 'left',
                    width: 240,
                    duration: 0.5,
                    timingFunction: 'ease',
                    shadowStyle: '0px 0px 0px #000'
                });

                $("#paneToggle").click(function() {
                    settingsPane.toggle()
                });

                $("#containWrapper").click(function() {
                    settingsPane.close()
                });
            }, 0);
        }
    }
});

/*
var preInterceptor = function($q, $location) {
    return function( promise ) {
        $("#loadingScreen").show();
        return promise;
    }
};
*/
var interceptor = function($q, $location, authenticateService) {
    return function(promise) {
        var resolve = function(value) {
            if (value.redirect) {
                alert('redirect');
                $location.path("/authenticate/login");
                //$("#loadingScreen").hide();
                return;
            }
        };
 
        var reject = function(reason) {
            if (reason.status == 401 && reason.data.error == 0) {
                if (authenticateService.getReqPath() == '') {
                    authenticateService.setReqPath($location.path());
                }
                $location.path("/authenticate/login");
                //$("#loadingScreen").hide();
                return;
            }
        };

        promise.then(resolve, reject);
        return promise;
    }
};
 
AnnoTree.directive('backImg', function() {
    return function(scope, element, attrs){
        attrs.$observe('backImg', function(value) {
            element.css({
                'background-image': 'url(' + value +')'
            });
        });
    };
});

AnnoTree.filter('reverse', function() {
    return function(items) {
        return items.slice().reverse();
    };
});

/*
$(document).ready(function() {
    $(window).resize(function() {
        if(window.innerWidth > 767 && settingsPane.isOpen) {
            settingsPane.closeFast();
        }
    });
});
*/
