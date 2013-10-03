var AnnoTree = angular.module("AnnoTree", ['ui.sortable']); //, ['ngDragDrop'] 

angular.module('ui.sortable').value('uiSortableConfig', {
    sortable: {
        connectWith: '.branchColumnLeaves, .branch, #leavesSortable',
        containment: 'document',
        placeholder: "card-col-placeholder",
        start: function(evt, ui) {
            ui.placeholder.height(ui.item.height());
            if (ui.placeholder[0].localName == 'li') {
                ui.placeholder[0].className = 'card-leaf-placeholder';
                ui.placeholder.width(ui.item.width());
            }
            evt.stopPropagation();
        },
        revert: 'true',
        helper: function(evt, ui) {
            if (ui[0].localName == 'li') {
                var item = ui[0].innerHTML;
                var width = ui[0].clientWidth;
                var height = ui[0].clientHeight;
                var backgroundImage = ui[0].style.backgroundImage;
                var container = $('<div style="width:' + width + 'px;height:' + height + 'px;background-image:' + backgroundImage + ';background-size:cover;background-position:center;border-radius: 5px 5px 0 0;overflow:hidden"></div>');
                container.append(item);
                return container;
            } else {
                var width = ui[0].clientWidth - 30;
                var item = ui[0].firstElementChild.innerHTML;
                var container = $('<div style="width:' + width + 'px"></div>');
                container.append(item);
                return container;
            }
        },
        appendTo: 'body',
        opacity: 0.5,
        scroll: false,
        cursor: 'move'
    }
});

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
            .when("/app/docs", {
                action: "standard.docs.home"
            })
            .when("/app/docs/ios", {
                action: "standard.docs.ios"
            })            
            .when("/app/docs/chrome", {
                action: "standard.docs.chrome"
            })
            .when("/app/:forestID/:treeID/:branchID/:leafID", {
                action: "standard.tree"
            }) 
            .when("/app/:forestID/:treeID/:branchID", {
                action: "standard.tree"
            })            
            .when("/app/:forestID/:treeID", {
                action: "standard.tree"
            })
            .when("/forestFire", {
                action: "standard.forestFire"
            })
            .otherwise({
                redirectTo: "/authenticate/login"
            });
            /*
            .when("/app/:treeID/:leafID", {
                action: "standard.tree.leaf"
            })
            */
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
var interceptor = function($q, $location, dataService) {
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
                if (dataService.getReqPath() == '') {
                    dataService.setReqPath($location.path());
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
    return function(scope, element, attrs) {
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
