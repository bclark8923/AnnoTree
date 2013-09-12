(function( ng, app ){
    "use strict";

    app.controller("authenticate.LoginController",
        function($scope, $rootScope, localStorageService, $location, $http, apiRoot, requestContext, constants, dataService) {
            function setError(msg) {
                $scope.loginPassword = '';
                $scope.errorText = msg;
                $scope.errorMessage = true;
            } 
            
            $scope.validateLogin = function() {
                var email = $scope.loginEmail;
                var password = $scope.loginPassword;
                var loginValid = $scope.loginForm.$valid;

                if (!loginValid) {
                    if (!email) {
                        setError('Please enter a valid email');
                    } else if (!password) {
                        setError('Please enter a valid password');
                    } else {
                        setError('Please enter valid information');
                    }
                } else {
                    $('#authenticateWorking').addClass('active');
                    var promise = $http.post(apiRoot.getRoot() + '/services/user/login', {
                        loginEmail: email, 
                        loginPassword: password
                    });

                    promise.then(
                        function(response) {
                            $('#authenticateWorking').removeClass('active'); // TODO: angular way
                            dataService.setUser(response.data);
                            var reqPath = dataService.getReqPath();
                            if (reqPath != '') {
                                dataService.setReqPath('');
                                $location.path(reqPath);
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
            $scope.errorMessage = false;
            $scope.setWindowTitle("AnnoTree");
        }
    );
})(angular, AnnoTree);
