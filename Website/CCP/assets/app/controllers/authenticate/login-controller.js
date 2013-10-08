(function( ng, app ){
    "use strict";

    app.controller("authenticate.LoginController",
        function($scope, $rootScope, $location, $http, apiRoot, requestContext, constants, dataService) {
            function setError(msg) {
                $scope.loginPassword = '';
                $scope.errorText = msg;
            } 

            function validateEmail(email) { 
                var re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
                return re.test(email);
            }

            $scope.validateLogin = function() {
                var email = $scope.loginEmail;
                var password = $scope.loginPassword;

                if (!validateEmail(email)) {
                    setError('Please enter a valid email');
                } else if (!password) {
                    setError('Please enter a valid password');
                } else {
                    $('#authenticateWorking').addClass('active');
                    var promise = $http.post(apiRoot.getRoot() + '/services/user/login', {
                        loginEmail: email, 
                        loginPassword: password
                    });

                    promise.then(
                        function(response) {
                            $scope.errorText = '';
                            $('#authenticateWorking').removeClass('active'); // TODO: angular way
                            dataService.setUser(response.data);
                            var reqPath = dataService.getReqPath();
                            if (reqPath != '') {
                                dataService.setReqPath('');
                                var forestFire = new RegExp('forestFire');
                                if (forestFire.test(reqPath)) {
                                    $location.path("app");
                                } else {
                                    $location.path(reqPath);
                                }
                            } else {
                                $location.path("app");
                            }
                        },
                        function(response) {
                            if (response.status != 500  && response.status != 502) {
                                setError(response.data.txt);
                            } else {
                                setError(constants.servicesDown());
                            }
                            $('#authenticateWorking').removeClass('active'); // TODO: angular way
                        }
                    );
                }
            }

            var renderContext = requestContext.getRenderContext("authenticate.login");
            $scope.subview = renderContext.getNextSection();
            $scope.$on("requestContextChanged", function() {
                if (!renderContext.isChangeRelevant()) {
                    return;
                }
                $scope.subview = renderContext.getNextSection();
            });

            //TODO:Move into main section
            $("#loadingScreen").hide(); // TODO: angular way
            $scope.setWindowTitle("AnnoTree");
            $scope.errorText = '';
        }
    );
})(angular, AnnoTree);
