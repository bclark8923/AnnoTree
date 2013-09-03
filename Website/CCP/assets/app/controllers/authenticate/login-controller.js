(function( ng, app ){
    "use strict";

    app.controller("authenticate.LoginController",
        function($scope, $rootScope, localStorageService, $location, requestContext, authenticateService) {
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
                    $('#authenticateWorking').addClass('active'); // TODO: way to handle this in angular?
                    var promise = authenticateService.login(email, password);

                    promise.then(
                        function(response) {
                            // this should just redirect to main app where the user information is then loaded
                            //set session information TODO: remove this
                            $('#authenticateWorking').removeClass('active'); // TODO: angular way
                            //localStorageService.add('username', response.data.first_name + ' ' + response.data.last_name);
                            //localStorageService.add('useravatar', response.data.profile_image_path);
                            //$rootScope.user = response.data; //TODO:is this used?
                            $location.path("app");
                        },
                        function(response) {
                            if (response.status != 500  && response.status != 502) {
                                setError(response.data.txt);
                            } else {
                                setError('AnnoTree is currently down.  Try again in a few minutes or contact us at support@annotree.com');
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
            $("#loadingScreen").hide();
            $scope.errorMessage = false;
            $scope.setWindowTitle("AnnoTree");
        }
    );
})(angular, AnnoTree);
